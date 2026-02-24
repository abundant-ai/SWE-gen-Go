package redis_test

import (
	"strings"
	"testing"

	"github.com/redis/go-redis/v9"
)

func TestClientNilOptions(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("NewClient(nil) should panic")
		} else {
			// Check for explicit panic message, not nil pointer dereference
			msg := r.(string)
			if !strings.Contains(msg, "nil options") {
				t.Errorf("Expected explicit panic message about nil options, got: %v", r)
			}
		}
	}()
	redis.NewClient(nil)
}

func TestClusterClientNilOptions(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("NewClusterClient(nil) should panic")
		} else {
			msg := r.(string)
			if !strings.Contains(msg, "nil options") {
				t.Errorf("Expected explicit panic message about nil options, got: %v", r)
			}
		}
	}()
	redis.NewClusterClient(nil)
}

func TestRingNilOptions(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("NewRing(nil) should panic")
		} else {
			msg := r.(string)
			if !strings.Contains(msg, "nil options") {
				t.Errorf("Expected explicit panic message about nil options, got: %v", r)
			}
		}
	}()
	redis.NewRing(nil)
}

func TestUniversalClientNilOptions(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("NewUniversalClient(nil) should panic")
		} else {
			msg := r.(string)
			if !strings.Contains(msg, "nil options") {
				t.Errorf("Expected explicit panic message about nil options, got: %v", r)
			}
		}
	}()
	redis.NewUniversalClient(nil)
}

func TestFailoverClientNilOptions(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("NewFailoverClient(nil) should panic")
		} else {
			msg := r.(string)
			if !strings.Contains(msg, "nil options") {
				t.Errorf("Expected explicit panic message about nil options, got: %v", r)
			}
		}
	}()
	redis.NewFailoverClient(nil)
}

func TestFailoverClusterClientNilOptions(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("NewFailoverClusterClient(nil) should panic")
		} else {
			msg := r.(string)
			if !strings.Contains(msg, "nil options") {
				t.Errorf("Expected explicit panic message about nil options, got: %v", r)
			}
		}
	}()
	redis.NewFailoverClusterClient(nil)
}

func TestSentinelClientNilOptions(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("NewSentinelClient(nil) should panic")
		} else {
			msg := r.(string)
			if !strings.Contains(msg, "nil options") {
				t.Errorf("Expected explicit panic message about nil options, got: %v", r)
			}
		}
	}()
	redis.NewSentinelClient(nil)
}
