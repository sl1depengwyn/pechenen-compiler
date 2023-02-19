# pechenen-compiler
Compiler for lisp-like language


## Some examples of code written in pechenen-lisp

```go
(func Fibonacci (n) (
  cond (less n 2) 
    (return n) 
    (return (plus (Fibonacci (minus n 1)) (Fibonacci (minus n 2)))))
)
```

```go
(func Gcd (a b) (
  cond (equal a b) 
    (return a) (
    cond (greater a b) 
      (return (Gcd b (minus a b))) 
      (return (Gcd a (minus b a))) 
    )
  )
)
```
