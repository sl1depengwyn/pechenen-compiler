# pechenen-compiler
Compiler for lisp-like language


## An example of code written in pechenen-lisp

```go
(func Fibonacci (n) (
  cond (less n 2) 
    (return n) 
    (return (plus (Fibonacci (minus n 1)) (Fibonacci (minus n 2)))))
)
```
