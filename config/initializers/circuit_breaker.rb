Workarea::CircuitBreaker.add_service(:taxjar_service, { max_fails: 20, break_for: 5.minutes, window: 5.minutes })
