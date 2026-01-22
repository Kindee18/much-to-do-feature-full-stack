package config

import (
	"fmt"
	"os"
	"strconv"
)

// Config stores all configuration of the application.
type Config struct {
	ServerPort         string   `mapstructure:"PORT"`
	MongoURI           string   `mapstructure:"MONGO_URI"`
	DBName             string   `mapstructure:"DB_NAME"`
	JWTSecretKey       string   `mapstructure:"JWT_SECRET_KEY"`
	JWTExpirationHours int      `mapstructure:"JWT_EXPIRATION_HOURS"`
	EnableCache        bool     `mapstructure:"ENABLE_CACHE"`
	RedisAddr          string   `mapstructure:"REDIS_ADDR"`
	RedisPassword      string   `mapstructure:"REDIS_PASSWORD"`
	LogLevel           string   `mapstructure:"LOG_LEVEL"`
	LogFormat          string   `mapstructure:"LOG_FORMAT"`
	CookieDomains      []string `mapstructure:"COOKIE_DOMAINS"`
	SecureCookie       bool     `mapstructure:"SECURE_COOKIE"`
	AllowedOrigins     []string `mapstructure:"ALLOWED_ORIGINS"`
}

// LoadConfig reads configuration from environment variables
func LoadConfig(path string) (config Config, err error) {
	fmt.Fprintf(os.Stderr, "==== CONFIG LOAD START: MONGO_URI env=%s
", os.Getenv("MONGO_URI"))
	config.ServerPort = os.Getenv("PORT")
	if config.ServerPort == "" {
		config.ServerPort = "8080"
	}
	config.MongoURI = os.Getenv("MONGO_URI")
	config.DBName = os.Getenv("DB_NAME")
	if config.DBName == "" {
		config.DBName = "much_todo_db"
	}
	config.LogLevel = os.Getenv("LOG_LEVEL")
	if config.LogLevel == "" {
		config.LogLevel = "INFO"
	}
	config.LogFormat = os.Getenv("LOG_FORMAT")
	if config.LogFormat == "" {
		config.LogFormat = "json"
	}
	enableCacheStr := os.Getenv("ENABLE_CACHE")
	if enableCacheStr != "" {
		config.EnableCache, _ = strconv.ParseBool(enableCacheStr)
	}
	config.RedisAddr = os.Getenv("REDIS_ADDR")
	if config.RedisAddr == "" {
		config.RedisAddr = "localhost:6379"
	}
	config.JWTSecretKey = os.Getenv("JWT_SECRET_KEY")
	if config.JWTSecretKey == "" {
		config.JWTSecretKey = "your-super-secret-key-change-in-production"
	}
	config.JWTExpirationHours = 72
	config.RedisPassword = os.Getenv("REDIS_PASSWORD")
	config.SecureCookie = false
	config.AllowedOrigins = []string{"http://localhost:5173"}
	config.CookieDomains = []string{"localhost"}

	fmt.Fprintf(os.Stderr, "DEBUG CONFIG: MONGO_URI=%s LOG_LEVEL=%s ENABLE_CACHE=%v\n", config.MongoURI, config.LogLevel, config.EnableCache)
	return
}
