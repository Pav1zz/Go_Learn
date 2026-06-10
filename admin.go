package main

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
)

type ctxAdminKey string

const adminUserIDKey ctxAdminKey = "adminUserID"

func adminMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		auth := r.Header.Get("Authorization")
		if !strings.HasPrefix(auth, "Bearer ") {
			adminJSON(w, http.StatusUnauthorized, map[string]string{"error": "token required"})
			return
		}
		uid, err := parseToken(strings.TrimPrefix(auth, "Bearer "))
		if err != nil {
			adminJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid token"})
			return
		}

		var role string
		err = DB.QueryRow(r.Context(), "SELECT role FROM users WHERE id=$1", uid).Scan(&role)
		if err != nil {
			adminJSON(w, http.StatusUnauthorized, map[string]string{"error": "user not found"})
			return
		}
		if role != "admin" {
			adminJSON(w, http.StatusForbidden, map[string]string{"error": "admin access required"})
			return
		}

		ctx := context.WithValue(r.Context(), adminUserIDKey, uid)
		next(w, r.WithContext(ctx))
	}
}

//	Структура запросов (добавить урок/обновить)

type AdminLessonRequest struct {
	Title      string   `json:"title"`
	Theory     string   `json:"theory"`
	Question   string   `json:"question"`
	Options    []string `json:"options"`
	Answer     int      `json:"answer"`
	Difficulty string   `json:"difficulty"`
	Category   string   `json:"category"`
	XPReward   int      `json:"xp_reward"`
}

//	POST /admin/lessons — добавить новый урок

func adminCreateLessonHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		adminJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req AdminLessonRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		adminJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid body"})
		return
	}
	if strings.TrimSpace(req.Title) == "" || strings.TrimSpace(req.Question) == "" {
		adminJSON(w, http.StatusBadRequest, map[string]string{"error": "title and question are required"})
		return
	}
	if req.Difficulty == "" {
		req.Difficulty = "easy"
	}
	if req.XPReward == 0 {
		req.XPReward = 10
	}

	optsJSON, _ := json.Marshal(req.Options) // []string -> JSONB

	var newID int
	err := DB.QueryRow(r.Context(),
		`INSERT INTO lessons (title, theory, question, options, answer, difficulty, category, xp_reward)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
		req.Title, req.Theory, req.Question, string(optsJSON),
		req.Answer, req.Difficulty, req.Category, req.XPReward,
	).Scan(&newID)
	if err != nil {
		adminJSON(w, http.StatusInternalServerError, map[string]string{"error": "insert failed"})
		return
	}

	adminJSON(w, http.StatusOK, map[string]interface{}{"status": "created", "id": newID})
}

//	PUT /admin/lessons/{id}   — обновить урок
//	DELETE /admin/lessons/{id} — удалить урок

func adminLessonByIDHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/admin/lessons/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		adminJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid id"})
		return
	}

	switch r.Method {
	case http.MethodPut:
		var req AdminLessonRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			adminJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid body"})
			return
		}
		if req.Difficulty == "" {
			req.Difficulty = "easy"
		}
		if req.XPReward == 0 {
			req.XPReward = 10
		}
		optsJSON, _ := json.Marshal(req.Options)

		ct, err := DB.Exec(r.Context(),
			`UPDATE lessons
			 SET title=$1, theory=$2, question=$3, options=$4, answer=$5, difficulty=$6, category=$7, xp_reward=$8
			 WHERE id=$9`,
			req.Title, req.Theory, req.Question, string(optsJSON),
			req.Answer, req.Difficulty, req.Category, req.XPReward, id,
		)
		if err != nil {
			adminJSON(w, http.StatusInternalServerError, map[string]string{"error": "update failed"})
			return
		}
		if ct.RowsAffected() == 0 {
			adminJSON(w, http.StatusNotFound, map[string]string{"error": "lesson not found"})
			return
		}
		adminJSON(w, http.StatusOK, map[string]string{"status": "updated"})

	case http.MethodDelete:
		ct, err := DB.Exec(r.Context(), "DELETE FROM lessons WHERE id=$1", id)
		if err != nil {
			adminJSON(w, http.StatusInternalServerError, map[string]string{"error": "delete failed"})
			return
		}
		if ct.RowsAffected() == 0 {
			adminJSON(w, http.StatusNotFound, map[string]string{"error": "lesson not found"})
			return
		}
		adminJSON(w, http.StatusOK, map[string]string{"status": "deleted"})

	default:
		adminJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
	}
}

//  GET /admin/users — что бы видит всех пользователей

type AdminUserRow struct {
	ID     int    `json:"id"`
	Email  string `json:"email"`
	XP     int    `json:"xp"`
	Streak int    `json:"streak"`
	Role   string `json:"role"`
}

func adminListUsersHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		adminJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	rows, err := DB.Query(r.Context(),
		"SELECT id, email, xp, streak, role FROM users ORDER BY id")
	if err != nil {
		adminJSON(w, http.StatusInternalServerError, map[string]string{"error": "query failed"})
		return
	}
	defer rows.Close()

	users := []AdminUserRow{}
	for rows.Next() {
		var u AdminUserRow
		if err := rows.Scan(&u.ID, &u.Email, &u.XP, &u.Streak, &u.Role); err != nil {
			continue
		}
		users = append(users, u)
	}

	adminJSON(w, http.StatusOK, users)
}

func adminUserByIDHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		adminJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	idStr := strings.TrimPrefix(r.URL.Path, "/admin/users/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		adminJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid id"})
		return
	}

	if adminID, ok := r.Context().Value(adminUserIDKey).(int); ok && adminID == id {
		adminJSON(w, http.StatusBadRequest, map[string]string{"error": "cannot delete yourself"})
		return
	}

	ct, err := DB.Exec(r.Context(), "DELETE FROM users WHERE id=$1", id)
	if err != nil {
		adminJSON(w, http.StatusInternalServerError, map[string]string{"error": "delete failed"})
		return
	}
	if ct.RowsAffected() == 0 {
		adminJSON(w, http.StatusNotFound, map[string]string{"error": "user not found"})
		return
	}

	adminJSON(w, http.StatusOK, map[string]string{"status": "deleted"})
}

func adminJSON(w http.ResponseWriter, code int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(v)
}
