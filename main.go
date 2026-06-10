package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"

	_ "goedu-backend/docs"

	httpSwagger "github.com/swaggo/http-swagger/v2"
)

// lessonsRouter Routing:
// GET  /lessons          list of lessons
// GET  /lessons/{id}      one lesson
// POST /lessons/{id}/submit  sending a response (requires Bearer token)
func lessonsRouter(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/lessons" {
		lessonsListHandler(w, r)
		return
	}

	if strings.HasPrefix(r.URL.Path, "/lessons/") {
		if strings.HasSuffix(r.URL.Path, "/submit") {
			authMiddleware(submitHandler)(w, r)
			return
		}
		lessonGetHandler(w, r)
		return
	}

	http.NotFound(w, r)
}

// @title           GoEdu API
// @version         1.0
// @description     Desktop app for learn Go
// @host            localhost:8080
// @BasePath        /
//
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	InitDB()
	defer DB.Close()

	mux := http.NewServeMux()

	// healthcheck / ping
	mux.HandleFunc("/ping", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	})

	// auth
	mux.HandleFunc("/register", registerHandler)
	mux.HandleFunc("/login", loginHandler)
	mux.HandleFunc("/me", authMiddleware(meHandler))
	mux.HandleFunc("/me/update", authMiddleware(updateProfileHandler))
	mux.HandleFunc("/me/password", authMiddleware(changePasswordHandler))

	// lessons
	mux.HandleFunc("/lessons", lessonsRouter)
	mux.HandleFunc("/lessons/", lessonsRouter)

	// progress
	mux.HandleFunc("/progress", authMiddleware(progressHandler))

	// leaderboard
	mux.HandleFunc("/leaderboard", authMiddleware(leaderboardHandler))

	// Admin
	mux.HandleFunc("/admin/lessons", adminMiddleware(adminCreateLessonHandler))
	mux.HandleFunc("/admin/lessons/", adminMiddleware(adminLessonByIDHandler))
	mux.HandleFunc("/admin/users", adminMiddleware(adminListUsersHandler))
	mux.HandleFunc("/admin/users/", adminMiddleware(adminUserByIDHandler))

	// swagger
	mux.Handle("/swagger/", httpSwagger.WrapHandler)

	// frontend
	mux.Handle("/", http.FileServer(http.Dir("./frontend")))

	// middlewares
	var handler http.Handler = mux
	handler = withCORS(handler)
	handler = withLogging(handler)

	log.Println("Server on :8080")
	go openBrowser("http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", handler))
}
