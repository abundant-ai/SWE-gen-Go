package main

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/labstack/echo/engine/standard"
	"github.com/labstack/gommon/log"
)

func main() {
	// Create a test HTTP request with X-Real-IP header
	httpReq, _ := http.NewRequest("GET", "http://example.com", nil)
	httpReq.Header.Set("X-Real-IP", "192.168.1.1")
	httpReq.RemoteAddr = "127.0.0.1:12345"
	
	req := standard.NewRequest(httpReq, log.New("test"))
	
	// Try to call RealIP() - this will fail to compile if RealIP() doesn't exist
	realIP := req.RealIP()
	
	// Verify the result
	if realIP != "192.168.1.1" {
		fmt.Printf("FAIL: Expected RealIP() to return '192.168.1.1', got '%s'\n", realIP)
		panic("RealIP check failed")
	}
	
	// Test with X-Forwarded-For
	httpReq2, _ := http.NewRequest("GET", "http://example.com", nil)
	httpReq2.Header.Set("X-Forwarded-For", "10.0.0.1")
	httpReq2.RemoteAddr = "127.0.0.1:12345"
	req2 := standard.NewRequest(httpReq2, log.New("test"))
	realIP2 := req2.RealIP()
	if realIP2 != "10.0.0.1" {
		fmt.Printf("FAIL: Expected RealIP() with X-Forwarded-For to return '10.0.0.1', got '%s'\n", realIP2)
		panic("RealIP check failed")
	}
	
	// Test fallback to RemoteAddress (without port)
	httpReq3, _ := http.NewRequest("GET", "http://example.com", nil)
	httpReq3.RemoteAddr = "127.0.0.1:54321"
	req3 := standard.NewRequest(httpReq3, log.New("test"))
	realIP3 := req3.RealIP()
	if !strings.HasPrefix(realIP3, "127.0.0.1") {
		fmt.Printf("FAIL: Expected RealIP() to return IP without port, got '%s'\n", realIP3)
		panic("RealIP check failed")
	}
	
	fmt.Println("PASS: All RealIP() checks passed")
}
