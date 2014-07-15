;; -*- lexical-binding: t -*-


(byte-compile-file "dash.el")
(require 'dash)

(defun even? (num) (= 0 (% num 2)))
(defun square (num) (* num num))
(defun three-letters () '("A" "B" "C"))

(ert-deftest -map ()
  (should (equal (-map (lambda (num) (* num num)) '(1 2 3 4)) '(1 4 9 16)))
  (should (equal (-map 'square '(1 2 3 4)) '(1 4 9 16)))
  (should (equal (--map (* it it) '(1 2 3 4)) '(1 4 9 16)))
  (should (equal (--map (concat it it) (three-letters)) '("AA" "BB" "CC"))))

(ert-deftest -map-when ()
  (should (equal (-map-when 'even? 'square '(1 2 3 4)) '(1 4 3 16)))
  (should (equal (--map-when (> it 2) (* it it) '(1 2 3 4)) '(1 2 9 16)))
  (should (equal (--map-when (= it 2) 17 '(1 2 3 4)) '(1 17 3 4)))
  (should (equal (-map-when (lambda (n) (= n 3)) (lambda (n) 0) '(1 2 3 4)) '(1 2 0 4))))

(ert-deftest -map-indexed ()
  (should (equal (-map-indexed (lambda (index item) (- item index)) '(1 2 3 4)) '(1 1 1 1)))
  (should (equal (--map-indexed (- it it-index) '(1 2 3 4)) '(1 1 1 1))))

(ert-deftest -annotate ()
  (should (equal (-annotate '1+ '(1 2 3)) '((2 . 1) (3 . 2) (4 . 3))))
  (should (equal (-annotate 'length '(("h" "e" "l" "l" "o") ("hello" "world"))) '((5 . ("h" "e" "l" "l" "o")) (2 . ("hello" "world")))))
  (should (equal (--annotate (< 1 it) '(0 1 2 3)) '((nil . 0) (nil . 1) (t . 2) (t . 3)))))

(ert-deftest -splice ()
  (should (equal (-splice 'even? (lambda (x) (list x x)) '(1 2 3 4)) '(1 2 2 3 4 4)))
  (should (equal (--splice 't (list it it) '(1 2 3 4)) '(1 1 2 2 3 3 4 4)))
  (should (equal (--splice (equal it :magic) '((list of) (magical) (code)) '((foo) (bar) :magic (baz))) '((foo) (bar) (list of) (magical) (code) (baz)))))

(ert-deftest -splice-list ()
  (should (equal (-splice-list 'keywordp '(a b c) '(1 :foo 2)) '(1 a b c 2)))
  (should (equal (-splice-list 'keywordp nil '(1 :foo 2)) '(1 2))))

(ert-deftest -mapcat ()
  (should (equal (-mapcat 'list '(1 2 3)) '(1 2 3)))
  (should (equal (-mapcat (lambda (item) (list 0 item)) '(1 2 3)) '(0 1 0 2 0 3)))
  (should (equal (--mapcat (list 0 it) '(1 2 3)) '(0 1 0 2 0 3))))

(ert-deftest -copy ()
  (should (equal (-copy '(1 2 3)) '(1 2 3)))
  (should (equal (let ((a '(1 2 3))) (eq a (-copy a))) nil)))

(ert-deftest -filter ()
  (should (equal (-filter (lambda (num) (= 0 (% num 2))) '(1 2 3 4)) '(2 4)))
  (should (equal (-filter 'even? '(1 2 3 4)) '(2 4)))
  (should (equal (--filter (= 0 (% it 2)) '(1 2 3 4)) '(2 4))))

(ert-deftest -remove ()
  (should (equal (-remove (lambda (num) (= 0 (% num 2))) '(1 2 3 4)) '(1 3)))
  (should (equal (-remove 'even? '(1 2 3 4)) '(1 3)))
  (should (equal (--remove (= 0 (% it 2)) '(1 2 3 4)) '(1 3)))
  (should (equal (let ((mod 2)) (-remove (lambda (num) (= 0 (% num mod))) '(1 2 3 4))) '(1 3)))
  (should (equal (let ((mod 2)) (--remove (= 0 (% it mod)) '(1 2 3 4))) '(1 3))))

(ert-deftest -slice ()
  (should (equal (-slice '(1 2 3 4 5) 1) '(2 3 4 5)))
  (should (equal (-slice '(1 2 3 4 5) 0 3) '(1 2 3)))
  (should (equal (-slice '(1 2 3 4 5 6 7 8 9) 1 -1 2) '(2 4 6 8)))
  (should (equal (-slice '(1 2 3 4 5) 0 10) '(1 2 3 4 5))) ;; "to > length" should not fill in nils!
  (should (equal (-slice '(1 2 3 4 5) -3) '(3 4 5)))
  (should (equal (-slice '(1 2 3 4 5) -3 -1) '(3 4)))
  (should (equal (-slice '(1 2 3 4 5 6) 0 nil 1) '(1 2 3 4 5 6)))
  (should (equal (-slice '(1 2 3 4 5 6) 0 nil 2) '(1 3 5)))
  (should (equal (-slice '(1 2 3 4 5 6) 0 nil 3) '(1 4)))
  (should (equal (-slice '(1 2 3 4 5 6) 0 nil 10) '(1)))
  (should (equal (-slice '(1 2 3 4 5 6) 1 4 2) '(2 4)))
  (should (equal (-slice '(1 2 3 4 5 6) 2 6 3) '(3 6)))
  (should (equal (-slice '(1 2 3 4 5 6) 2 -1 2) '(3 5)))
  (should (equal (-slice '(1 2 3 4 5 6) -4 -1 2) '(3 5)))
  (should (equal (-slice '(1 2 3 4 5 6) 1 2 10) '(2))))

(ert-deftest -take ()
  (should (equal (-take 3 '(1 2 3 4 5)) '(1 2 3)))
  (should (equal (-take 17 '(1 2 3 4 5)) '(1 2 3 4 5))))

(ert-deftest -drop ()
  (should (equal (-drop 3 '(1 2 3 4 5)) '(4 5)))
  (should (equal (-drop 17 '(1 2 3 4 5)) '())))

(ert-deftest -take-while ()
  (should (equal (-take-while 'even? '(1 2 3 4)) '()))
  (should (equal (-take-while 'even? '(2 4 5 6)) '(2 4)))
  (should (equal (--take-while (< it 4) '(1 2 3 4 3 2 1)) '(1 2 3))))

(ert-deftest -drop-while ()
  (should (equal (-drop-while 'even? '(1 2 3 4)) '(1 2 3 4)))
  (should (equal (-drop-while 'even? '(2 4 5 6)) '(5 6)))
  (should (equal (--drop-while (< it 4) '(1 2 3 4 3 2 1)) '(4 3 2 1))))

(ert-deftest -select-by-indices ()
  (should (equal (-select-by-indices '(4 10 2 3 6) '("v" "e" "l" "o" "c" "i" "r" "a" "p" "t" "o" "r")) '("c" "o" "l" "o" "r")))
  (should (equal (-select-by-indices '(2 1 0) '("a" "b" "c")) '("c" "b" "a")))
  (should (equal (-select-by-indices '(0 1 2 0 1 3 3 1) '("f" "a" "r" "l")) '("f" "a" "r" "f" "a" "l" "l" "a"))))

(ert-deftest -keep ()
  (should (equal (-keep 'cdr '((1 2 3) (4 5) (6))) '((2 3) (5))))
  (should (equal (-keep (lambda (num) (when (> num 3) (* 10 num))) '(1 2 3 4 5 6)) '(40 50 60)))
  (should (equal (--keep (when (> it 3) (* 10 it)) '(1 2 3 4 5 6)) '(40 50 60))))

(ert-deftest -concat ()
  (should (equal (-concat '(1)) '(1)))
  (should (equal (-concat '(1) '(2)) '(1 2)))
  (should (equal (-concat '(1) '(2 3) '(4)) '(1 2 3 4)))
  (should (equal (-concat) nil)))

(ert-deftest -flatten ()
  (should (equal (-flatten '((1))) '(1)))
  (should (equal (-flatten '((1 (2 3) (((4 (5))))))) '(1 2 3 4 5)))
  (should (equal (-flatten '(1 2 (3 . 4))) '(1 2 (3 . 4)))))

(ert-deftest -flatten-n ()
  (should (equal (-flatten-n 1 '((1 2) ((3 4) ((5 6))))) '(1 2 (3 4) ((5 6)))))
  (should (equal (-flatten-n 2 '((1 2) ((3 4) ((5 6))))) '(1 2 3 4 (5 6))))
  (should (equal (-flatten-n 3 '((1 2) ((3 4) ((5 6))))) '(1 2 3 4 5 6)))
  (should (equal (-flatten-n 0 '(3 4)) '(3 4)))
  (should (equal (-flatten-n 0 '((1 2) (3 4))) '((1 2) (3 4))))
  (should (equal (-flatten-n 0 '(((1 2) (3 4)))) '(((1 2) (3 4))))))

(ert-deftest -replace ()
  (should (equal (-replace 1 "1" '(1 2 3 4 3 2 1)) '("1" 2 3 4 3 2 "1")))
  (should (equal (-replace "foo" "bar" '("a" "nice" "foo" "sentence" "about" "foo")) '("a" "nice" "bar" "sentence" "about" "bar")))
  (should (equal (-replace 1 2 nil) nil)))

(ert-deftest -insert-at ()
  (should (equal (-insert-at 1 'x '(a b c)) '(a x b c)))
  (should (equal (-insert-at 12 'x '(a b c)) '(a b c x))))

(ert-deftest -replace-at ()
  (should (equal (-replace-at 0 9 '(0 1 2 3 4 5)) '(9 1 2 3 4 5)))
  (should (equal (-replace-at 1 9 '(0 1 2 3 4 5)) '(0 9 2 3 4 5)))
  (should (equal (-replace-at 4 9 '(0 1 2 3 4 5)) '(0 1 2 3 9 5)))
  (should (equal (-replace-at 5 9 '(0 1 2 3 4 5)) '(0 1 2 3 4 9))))

(ert-deftest -update-at ()
  (should (equal (-update-at 0 (lambda (x) (+ x 9)) '(0 1 2 3 4 5)) '(9 1 2 3 4 5)))
  (should (equal (-update-at 1 (lambda (x) (+ x 8)) '(0 1 2 3 4 5)) '(0 9 2 3 4 5)))
  (should (equal (--update-at 2 (length it) '("foo" "bar" "baz" "quux")) '("foo" "bar" 3 "quux")))
  (should (equal (--update-at 2 (concat it "zab") '("foo" "bar" "baz" "quux")) '("foo" "bar" "bazzab" "quux"))))

(ert-deftest -remove-at ()
  (should (equal (-remove-at 0 '("0" "1" "2" "3" "4" "5")) '("1" "2" "3" "4" "5")))
  (should (equal (-remove-at 1 '("0" "1" "2" "3" "4" "5")) '("0" "2" "3" "4" "5")))
  (should (equal (-remove-at 2 '("0" "1" "2" "3" "4" "5")) '("0" "1" "3" "4" "5")))
  (should (equal (-remove-at 3 '("0" "1" "2" "3" "4" "5")) '("0" "1" "2" "4" "5")))
  (should (equal (-remove-at 4 '("0" "1" "2" "3" "4" "5")) '("0" "1" "2" "3" "5")))
  (should (equal (-remove-at 5 '("0" "1" "2" "3" "4" "5")) '("0" "1" "2" "3" "4")))
  (should (equal (-remove-at 5 '((a b) (c d) (e f g) h i ((j) k) l (m))) '((a b) (c d) (e f g) h i l (m))))
  (should (equal (-remove-at 0 '(((a b) (c d) (e f g) h i ((j) k) l (m)))) nil)))

(ert-deftest -remove-at-indices ()
  (should (equal (-remove-at-indices '(0) '("0" "1" "2" "3" "4" "5")) '("1" "2" "3" "4" "5")))
  (should (equal (-remove-at-indices '(0 2 4) '("0" "1" "2" "3" "4" "5")) '("1" "3" "5")))
  (should (equal (-remove-at-indices '(0 5) '("0" "1" "2" "3" "4" "5")) '("1" "2" "3" "4")))
  (should (equal (-remove-at-indices '(1 2 3) '("0" "1" "2" "3" "4" "5")) '("0" "4" "5")))
  (should (equal (-remove-at-indices '(0 1 2 3 4 5) '("0" "1" "2" "3" "4" "5")) nil))
  (should (equal (-remove-at-indices '(2 0 4) '("0" "1" "2" "3" "4" "5")) '("1" "3" "5")))
  (should (equal (-remove-at-indices '(5 0) '("0" "1" "2" "3" "4" "5")) '("1" "2" "3" "4")))
  (should (equal (-remove-at-indices '(1 3 2) '("0" "1" "2" "3" "4" "5")) '("0" "4" "5")))
  (should (equal (-remove-at-indices '(0 3 4 2 5 1) '("0" "1" "2" "3" "4" "5")) nil))
  (should (equal (-remove-at-indices '(1) '("0" "1" "2" "3" "4" "5")) '("0" "2" "3" "4" "5")))
  (should (equal (-remove-at-indices '(2) '("0" "1" "2" "3" "4" "5")) '("0" "1" "3" "4" "5")))
  (should (equal (-remove-at-indices '(3) '("0" "1" "2" "3" "4" "5")) '("0" "1" "2" "4" "5")))
  (should (equal (-remove-at-indices '(4) '("0" "1" "2" "3" "4" "5")) '("0" "1" "2" "3" "5")))
  (should (equal (-remove-at-indices '(5) '("0" "1" "2" "3" "4" "5")) '("0" "1" "2" "3" "4")))
  (should (equal (-remove-at-indices '(1 2 4) '((a b) (c d) (e f g) h i ((j) k) l (m))) '((a b) h ((j) k) l (m))))
  (should (equal (-remove-at-indices '(5) '((a b) (c d) (e f g) h i ((j) k) l (m))) '((a b) (c d) (e f g) h i l (m))))
  (should (equal (-remove-at-indices '(0) '(((a b) (c d) (e f g) h i ((j) k) l (m)))) nil))
  (should (equal (-remove-at-indices '(2 3) '((0) (1) (2) (3) (4) (5) (6))) '((0) (1) (4) (5) (6)))))

(ert-deftest -reduce-from ()
  (should (equal (-reduce-from '- 10 '(1 2 3)) 4))
  (should (equal (-reduce-from (lambda (memo item)
                                 (concat "(" memo " - " (int-to-string item) ")")) "10" '(1 2 3)) "(((10 - 1) - 2) - 3)"))
  (should (equal (--reduce-from (concat acc " " it) "START" '("a" "b" "c")) "START a b c"))
  (should (equal (-reduce-from '+ 7 '()) 7))
  (should (equal (-reduce-from '+ 7 '(1)) 8)))

(ert-deftest -reduce-r-from ()
  (should (equal (-reduce-r-from '- 10 '(1 2 3)) -8))
  (should (equal (-reduce-r-from (lambda (item memo)
                                   (concat "(" (int-to-string item) " - " memo ")")) "10" '(1 2 3)) "(1 - (2 - (3 - 10)))"))
  (should (equal (--reduce-r-from (concat it " " acc) "END" '("a" "b" "c")) "a b c END"))
  (should (equal (-reduce-r-from '+ 7 '()) 7))
  (should (equal (-reduce-r-from '+ 7 '(1)) 8)))

(ert-deftest -reduce ()
  (should (equal (-reduce '- '(1 2 3 4)) -8))
  (should (equal (-reduce (lambda (memo item) (format "%s-%s" memo item)) '(1 2 3)) "1-2-3"))
  (should (equal (--reduce (format "%s-%s" acc it) '(1 2 3)) "1-2-3"))
  (should (equal (-reduce '+ '()) 0))
  (should (equal (-reduce '+ '(1)) 1))
  (should (equal (--reduce (format "%s-%s" acc it) '()) "nil-nil")))

(ert-deftest -reduce-r ()
  (should (equal (-reduce-r '- '(1 2 3 4)) -2))
  (should (equal (-reduce-r (lambda (item memo) (format "%s-%s" memo item)) '(1 2 3)) "3-2-1"))
  (should (equal (--reduce-r (format "%s-%s" acc it) '(1 2 3)) "3-2-1"))
  (should (equal (-reduce-r '+ '()) 0))
  (should (equal (-reduce-r '+ '(1)) 1))
  (should (equal (--reduce-r (format "%s-%s" it acc) '()) "nil-nil")))

(ert-deftest -count ()
  (should (equal (-count 'even? '(1 2 3 4 5)) 2))
  (should (equal (--count (< it 4) '(1 2 3 4)) 3)))

(ert-deftest -sum ()
  (should (equal (-sum '()) 0))
  (should (equal (-sum '(1)) 1))
  (should (equal (-sum '(1 2 3 4)) 10)))

(ert-deftest -product ()
  (should (equal (-product '()) 1))
  (should (equal (-product '(1)) 1))
  (should (equal (-product '(1 2 3 4)) 24)))

(ert-deftest -min ()
  (should (equal (-min '(0)) 0))
  (should (equal (-min '(3 2 1)) 1))
  (should (equal (-min '(1 2 3)) 1)))

(ert-deftest -min-by ()
  (should (equal (-min-by '> '(4 3 6 1)) 1))
  (should (equal (--min-by (> (car it) (car other)) '((1 2 3) (2) (3 2))) '(1 2 3)))
  (should (equal (--min-by (> (length it) (length other)) '((1 2 3) (2) (3 2))) '(2))))

(ert-deftest -max ()
  (should (equal (-max '(0)) 0))
  (should (equal (-max '(3 2 1)) 3))
  (should (equal (-max '(1 2 3)) 3)))

(ert-deftest -max-by ()
  (should (equal (-max-by '> '(4 3 6 1)) 6))
  (should (equal (--max-by (> (car it) (car other)) '((1 2 3) (2) (3 2))) '(3 2)))
  (should (equal (--max-by (> (length it) (length other)) '((1 2 3) (2) (3 2))) '(1 2 3))))

(ert-deftest -iterate ()
  (should (equal (-iterate '1+ 1 10) '(1 2 3 4 5 6 7 8 9 10)))
  (should (equal (-iterate (lambda (x) (+ x x)) 2 5) '(2 4 8 16 32)))
  (should (equal (--iterate (* it it) 2 5) '(2 4 16 256 65536))))

(ert-deftest -unfold ()
  (should (equal (-unfold (lambda (x) (unless (= x 0) (cons x (1- x)))) 10) '(10 9 8 7 6 5 4 3 2 1)))
  (should (equal (--unfold (when it (cons it (cdr it))) '(1 2 3 4)) '((1 2 3 4) (2 3 4) (3 4) (4))))
  (should (equal (--unfold (when it (cons it (butlast it))) '(1 2 3 4)) '((1 2 3 4) (1 2 3) (1 2) (1)))))

(ert-deftest -any? ()
  (should (equal (-any? 'even? '(1 2 3)) t))
  (should (equal (-any? 'even? '(1 3 5)) nil))
  (should (equal (--any? (= 0 (% it 2)) '(1 2 3)) t)))

(ert-deftest -all? ()
  (should (equal (-all? 'even? '(1 2 3)) nil))
  (should (equal (-all? 'even? '(2 4 6)) t))
  (should (equal (--all? (= 0 (% it 2)) '(2 4 6)) t)))

(ert-deftest -none? ()
  (should (equal (-none? 'even? '(1 2 3)) nil))
  (should (equal (-none? 'even? '(1 3 5)) t))
  (should (equal (--none? (= 0 (% it 2)) '(1 2 3)) nil)))

(ert-deftest -only-some? ()
  (should (equal (-only-some? 'even? '(1 2 3)) t))
  (should (equal (-only-some? 'even? '(1 3 5)) nil))
  (should (equal (-only-some? 'even? '(2 4 6)) nil))
  (should (equal (--only-some? (> it 2) '(1 2 3)) t)))

(ert-deftest -contains? ()
  (should (equal (-contains? '(1 2 3) 1) t))
  (should (equal (-contains? '(1 2 3) 2) t))
  (should (equal (-contains? '(1 2 3) 4) nil))
  (should (equal (-contains? '() 1) nil))
  (should (equal (-contains? '() '()) nil)))

(ert-deftest -same-items? ()
  (should (equal (-same-items? '(1 2 3) '(1 2 3)) t))
  (should (equal (-same-items? '(1 2 3) '(3 2 1)) t))
  (should (equal (-same-items? '(1 2 3) '(1 2 3 4)) nil))
  (should (equal (-same-items? '((a . 1) (b . 2)) '((a . 1) (b . 2))) t))
  (should (equal (-same-items? '(1 2 3) '(2 3 1)) t)))

(ert-deftest -is-prefix? ()
  (should (equal (-is-prefix? '(1 2 3) '(1 2 3 4 5)) t))
  (should (equal (-is-prefix? '(1 2 3 4 5) '(1 2 3)) nil))
  (should (equal (-is-prefix? '(1 3) '(1 2 3 4 5)) nil))
  (should (equal (-is-prefix? '(1 2 3) '(1 2 4 5)) nil)))

(ert-deftest -is-suffix? ()
  (should (equal (-is-suffix? '(3 4 5) '(1 2 3 4 5)) t))
  (should (equal (-is-suffix? '(1 2 3 4 5) '(3 4 5)) nil))
  (should (equal (-is-suffix? '(3 5) '(1 2 3 4 5)) nil))
  (should (equal (-is-suffix? '(3 4 5) '(1 2 3 5)) nil)))

(ert-deftest -is-infix? ()
  (should (equal (-is-infix? '(1 2 3) '(1 2 3 4 5)) t))
  (should (equal (-is-infix? '(2 3 4) '(1 2 3 4 5)) t))
  (should (equal (-is-infix? '(3 4 5) '(1 2 3 4 5)) t))
  (should (equal (-is-infix? '(2 3 4) '(1 2 4 5)) nil))
  (should (equal (-is-infix? '(2 4) '(1 2 3 4 5)) nil)))

(ert-deftest -split-at ()
  (should (equal (-split-at 3 '(1 2 3 4 5)) '((1 2 3) (4 5))))
  (should (equal (-split-at 17 '(1 2 3 4 5)) '((1 2 3 4 5) nil))))

(ert-deftest -split-with ()
  (should (equal (-split-with 'even? '(1 2 3 4)) '(() (1 2 3 4))))
  (should (equal (-split-with 'even? '(2 4 5 6)) '((2 4) (5 6))))
  (should (equal (--split-with (< it 4) '(1 2 3 4 3 2 1)) '((1 2 3) (4 3 2 1)))))

(ert-deftest -split-on ()
  (should (equal (-split-on '| '(Nil | Leaf a | Node [Tree a])) '((Nil) (Leaf a) (Node [Tree a]))))
  (should (equal (-split-on ':endgroup '("a" "b" :endgroup "c" :endgroup "d" "e")) '(("a" "b") ("c") ("d" "e"))))
  (should (equal (-split-on ':endgroup '("a" "b" :endgroup :endgroup "d" "e")) '(("a" "b") ("d" "e"))))
  (should (equal (-split-on ':endgroup '("a" "b" :endgroup "c" :endgroup)) '(("a" "b") ("c"))))
  (should (equal (-split-on ':endgroup '("a" "b" :endgroup :endgroup :endgroup "d" "e")) '(("a" "b") ("d" "e"))))
  (should (equal (-split-on ':endgroup '(:endgroup "c" :endgroup "d" "e")) '(("c") ("d" "e"))))
  (should (equal (-split-on '| '(Nil | | Node [Tree a])) '((Nil) (Node [Tree a])))))

(ert-deftest -split-when ()
  (should (equal (-split-when 'even? '(1 2 3 4 5 6)) '((1) (3) (5))))
  (should (equal (-split-when 'even? '(1 2 3 4 6 8 9)) '((1) (3) (9))))
  (should (equal (--split-when (memq it '(&optional &rest)) '(a b &optional c d &rest args)) '((a b) (c d) (args))))
  (should (equal (-split-when 'even? '(1 2 3 5 6)) '((1) (3 5))))
  (should (equal (-split-when 'even? '(1 2 3 5)) '((1) (3 5))))
  (should (equal (-split-when 'even? '(1 3 4 5 6)) '((1 3) (5))))
  (should (equal (-split-when 'even? '(1 2 3 4 5 6 8 10)) '((1) (3) (5))))
  (should (equal (-split-when 'even? '(1 2 3 5 7 6)) '((1) (3 5 7)))))

(ert-deftest -separate ()
  (should (equal (-separate (lambda (num) (= 0 (% num 2))) '(1 2 3 4 5 6 7)) '((2 4 6) (1 3 5 7))))
  (should (equal (--separate (< it 5) '(3 7 5 9 3 2 1 4 6)) '((3 3 2 1 4) (7 5 9 6))))
  (should (equal (-separate 'cdr '((1 2) (1) (1 2 3) (4))) '(((1 2) (1 2 3)) ((1) (4))))))

(ert-deftest -partition ()
  (should (equal (-partition 2 '(1 2 3 4 5 6)) '((1 2) (3 4) (5 6))))
  (should (equal (-partition 2 '(1 2 3 4 5 6 7)) '((1 2) (3 4) (5 6))))
  (should (equal (-partition 3 '(1 2 3 4 5 6 7)) '((1 2 3) (4 5 6)))))

(ert-deftest -partition-all ()
  (should (equal (-partition-all 2 '(1 2 3 4 5 6)) '((1 2) (3 4) (5 6))))
  (should (equal (-partition-all 2 '(1 2 3 4 5 6 7)) '((1 2) (3 4) (5 6) (7))))
  (should (equal (-partition-all 3 '(1 2 3 4 5 6 7)) '((1 2 3) (4 5 6) (7)))))

(ert-deftest -partition-in-steps ()
  (should (equal (-partition-in-steps 2 1 '(1 2 3 4)) '((1 2) (2 3) (3 4))))
  (should (equal (-partition-in-steps 3 2 '(1 2 3 4)) '((1 2 3))))
  (should (equal (-partition-in-steps 3 2 '(1 2 3 4 5)) '((1 2 3) (3 4 5))))
  (should (equal (-partition-in-steps 2 1 '(1)) '())))

(ert-deftest -partition-all-in-steps ()
  (should (equal (-partition-all-in-steps 2 1 '(1 2 3 4)) '((1 2) (2 3) (3 4) (4))))
  (should (equal (-partition-all-in-steps 3 2 '(1 2 3 4)) '((1 2 3) (3 4))))
  (should (equal (-partition-all-in-steps 3 2 '(1 2 3 4 5)) '((1 2 3) (3 4 5) (5))))
  (should (equal (-partition-all-in-steps 2 1 '(1)) '((1)))))

(ert-deftest -partition-by ()
  (should (equal (-partition-by 'even? '()) '()))
  (should (equal (-partition-by 'even? '(1 1 2 2 2 3 4 6 8)) '((1 1) (2 2 2) (3) (4 6 8))))
  (should (equal (--partition-by (< it 3) '(1 2 3 4 3 2 1)) '((1 2) (3 4 3) (2 1)))))

(ert-deftest -partition-by-header ()
  (should (equal (--partition-by-header (= it 1) '(1 2 3 1 2 1 2 3 4)) '((1 2 3) (1 2) (1 2 3 4))))
  (should (equal (--partition-by-header (> it 0) '(1 2 0 1 0 1 2 3 0)) '((1 2 0) (1 0) (1 2 3 0))))
  (should (equal (-partition-by-header 'even? '(2 1 1 1 4 1 3 5 6 6 1)) '((2 1 1 1) (4 1 3 5) (6 6 1)))))

(ert-deftest -group-by ()
  (should (equal (-group-by 'even? '()) '()))
  (should (equal (-group-by 'even? '(1 1 2 2 2 3 4 6 8)) '((nil . (1 1 3)) (t . (2 2 2 4 6 8)))))
  (should (equal (--group-by (car (split-string it "/")) '("a/b" "c/d" "a/e")) '(("a" . ("a/b" "a/e")) ("c" . ("c/d"))))))

(ert-deftest -elem-index ()
  (should (equal (-elem-index 2 '(6 7 8 2 3 4)) 3))
  (should (equal (-elem-index "bar" '("foo" "bar" "baz")) 1))
  (should (equal (-elem-index '(1 2) '((3) (5 6) (1 2) nil)) 2)))

(ert-deftest -elem-indices ()
  (should (equal (-elem-indices 2 '(6 7 8 2 3 4 2 1)) '(3 6)))
  (should (equal (-elem-indices "bar" '("foo" "bar" "baz")) '(1)))
  (should (equal (-elem-indices '(1 2) '((3) (1 2) (5 6) (1 2) nil)) '(1 3))))

(ert-deftest -find-index ()
  (should (equal (-find-index 'even? '(2 4 1 6 3 3 5 8)) 0))
  (should (equal (--find-index (< 5 it) '(2 4 1 6 3 3 5 8)) 3))
  (should (equal (-find-index (-partial 'string-lessp "baz") '("bar" "foo" "baz")) 1)))

(ert-deftest -find-last-index ()
  (should (equal (-find-last-index 'even? '(2 4 1 6 3 3 5 8)) 7))
  (should (equal (--find-last-index (< 5 it) '(2 7 1 6 3 8 5 2)) 5))
  (should (equal (-find-last-index (-partial 'string-lessp "baz") '("q" "foo" "baz")) 1)))

(ert-deftest -find-indices ()
  (should (equal (-find-indices 'even? '(2 4 1 6 3 3 5 8)) '(0 1 3 7)))
  (should (equal (--find-indices (< 5 it) '(2 4 1 6 3 3 5 8)) '(3 7)))
  (should (equal (-find-indices (-partial 'string-lessp "baz") '("bar" "foo" "baz")) '(1))))

(ert-deftest -grade-up ()
  (should (equal (-grade-up '< '(3 1 4 2 1 3 3)) '(1 4 3 0 5 6 2)))
  (should (equal (let ((l '(3 1 4 2 1 3 3))) (-select-by-indices (-grade-up '< l) l)) '(1 1 2 3 3 3 4))))

(ert-deftest -grade-down ()
  (should (equal (-grade-down '< '(3 1 4 2 1 3 3)) '(2 0 5 6 3 1 4)))
  (should (equal (let ((l '(3 1 4 2 1 3 3))) (-select-by-indices (-grade-down '< l) l)) '(4 3 3 3 2 1 1))))

(ert-deftest -union ()
  (should (equal (-union '(1 2 3) '(3 4 5)) '(1 2 3 4 5)))
  (should (equal (-union '(1 2 3 4) '()) '(1 2 3 4)))
  (should (equal (-union '(1 1 2 2) '(3 2 1)) '(1 1 2 2 3))))

(ert-deftest -difference ()
  (should (equal (-difference '() '()) '()))
  (should (equal (-difference '(1 2 3) '(4 5 6)) '(1 2 3)))
  (should (equal (-difference '(1 2 3 4) '(3 4 5 6)) '(1 2))))

(ert-deftest -intersection ()
  (should (equal (-intersection '() '()) '()))
  (should (equal (-intersection '(1 2 3) '(4 5 6)) '()))
  (should (equal (-intersection '(1 2 3 4) '(3 4 5 6)) '(3 4))))

(ert-deftest -distinct ()
  (should (equal (-distinct '()) '()))
  (should (equal (-distinct '(1 2 2 4)) '(1 2 4))))

(ert-deftest -rotate ()
  (should (equal (-rotate 3 '(1 2 3 4 5 6 7)) '(5 6 7 1 2 3 4)))
  (should (equal (-rotate -3 '(1 2 3 4 5 6 7)) '(4 5 6 7 1 2 3))))

(ert-deftest -repeat ()
  (should (equal (-repeat 3 :a) '(:a :a :a)))
  (should (equal (-repeat 1 :a) '(:a)))
  (should (equal (-repeat 0 :a) nil))
  (should (equal (-repeat -1 :a) nil)))

(ert-deftest -cons* ()
  (should (equal (-cons* 1 2) '(1 . 2)))
  (should (equal (-cons* 1 2 3) '(1 2 . 3)))
  (should (equal (-cons* 1) 1))
  (should (equal (-cons* 1 2 3 4) '(1 2 3 . 4)))
  (should (equal (apply '-cons* (number-sequence 1 10)) '(1 2 3 4 5 6 7 8 9 . 10))))

(ert-deftest -snoc ()
  (should (equal (-snoc '(1 2 3) 4) '(1 2 3 4)))
  (should (equal (-snoc '(1 2 3) 4 5 6) '(1 2 3 4 5 6)))
  (should (equal (-snoc '(1 2 3) '(4 5 6)) '(1 2 3 (4 5 6)))))

(ert-deftest -interpose ()
  (should (equal (-interpose "-" '()) '()))
  (should (equal (-interpose "-" '("a")) '("a")))
  (should (equal (-interpose "-" '("a" "b" "c")) '("a" "-" "b" "-" "c"))))

(ert-deftest -interleave ()
  (should (equal (-interleave '(1 2) '("a" "b")) '(1 "a" 2 "b")))
  (should (equal (-interleave '(1 2) '("a" "b") '("A" "B")) '(1 "a" "A" 2 "b" "B")))
  (should (equal (-interleave '(1 2 3) '("a" "b")) '(1 "a" 2 "b")))
  (should (equal (-interleave '(1 2 3) '("a" "b" "c" "d")) '(1 "a" 2 "b" 3 "c"))))

(ert-deftest -zip-with ()
  (should (equal (-zip-with '+ '(1 2 3) '(4 5 6)) '(5 7 9)))
  (should (equal (-zip-with 'cons '(1 2 3) '(4 5 6)) '((1 . 4) (2 . 5) (3 . 6))))
  (should (equal (--zip-with (concat it " and " other) '("Batman" "Jekyll") '("Robin" "Hyde")) '("Batman and Robin" "Jekyll and Hyde"))))

(ert-deftest -zip ()
  (should (equal (-zip '(1 2 3) '(4 5 6)) '((1 . 4) (2 . 5) (3 . 6))))
  (should (equal (-zip '(1 2 3) '(4 5 6 7)) '((1 . 4) (2 . 5) (3 . 6))))
  (should (equal (-zip '(1 2 3 4) '(4 5 6)) '((1 . 4) (2 . 5) (3 . 6))))
  (should (equal (-zip '(1 2 3) '(4 5 6) '(7 8 9)) '((1 4 7) (2 5 8) (3 6 9))))
  (should (equal (-zip '(1 2) '(3 4 5) '(6)) '((1 3 6)))))

(ert-deftest -zip-fill ()
  (should (equal (-zip-fill 0 '(1 2 3 4 5) '(6 7 8 9)) '((1 . 6) (2 . 7) (3 . 8) (4 . 9) (5 . 0)))))

(ert-deftest -cycle ()
  (should (equal (-take 5 (-cycle '(1 2 3))) '(1 2 3 1 2)))
  (should (equal (-take 7 (-cycle '(1 "and" 3))) '(1 "and" 3 1 "and" 3 1)))
  (should (equal (-zip (-cycle '(1 2 3)) '(1 2)) '((1 . 1) (2 . 2))))
  (should (equal (-zip-with 'cons (-cycle '(1 2 3)) '(1 2)) '((1 . 1) (2 . 2))))
  (should (equal (-map (-partial '-take 5) (-split-at 5 (-cycle '(1 2 3)))) '((1 2 3 1 2) (3 1 2 3 1)))))

(ert-deftest -pad ()
  (should (equal (-pad 0 '()) '(())))
  (should (equal (-pad 0 '(1)) '((1))))
  (should (equal (-pad 0 '(1 2 3) '(4 5)) '((1 2 3) (4 5 0))))
  (should (equal (-pad nil '(1 2 3) '(4 5) '(6 7 8 9 10)) '((1 2 3 nil nil) (4 5 nil nil nil) (6 7 8 9 10))))
  (should (equal (-pad 0 '(1 2) '(3 4)) '((1 2) (3 4)))))

(ert-deftest -table ()
  (should (equal (-table '* '(1 2 3) '(1 2 3)) '((1 2 3) (2 4 6) (3 6 9))))
  (should (equal (-table (lambda (a b) (-sum (-zip-with '* a b))) '((1 2) (3 4)) '((1 3) (2 4))) '((7 15) (10 22))))
  (should (equal (apply '-table 'list (-repeat 3 '(1 2))) '((((1 1 1) (2 1 1)) ((1 2 1) (2 2 1))) (((1 1 2) (2 1 2)) ((1 2 2) (2 2 2)))))))

(ert-deftest -table-flat ()
  (should (equal (-table-flat 'list '(1 2 3) '(a b c)) '((1 a) (2 a) (3 a) (1 b) (2 b) (3 b) (1 c) (2 c) (3 c))))
  (should (equal (-table-flat '* '(1 2 3) '(1 2 3)) '(1 2 3 2 4 6 3 6 9)))
  (should (equal (apply '-table-flat 'list (-repeat 3 '(1 2))) '((1 1 1) (2 1 1) (1 2 1) (2 2 1) (1 1 2) (2 1 2) (1 2 2) (2 2 2))))

  ;; flatten law tests
  (should (equal (-flatten-n 1 (-table 'list '(1 2 3) '(a b c))) '((1 a) (2 a) (3 a) (1 b) (2 b) (3 b) (1 c) (2 c) (3 c))))
  (should (equal (-flatten-n 1 (-table '* '(1 2 3) '(1 2 3))) '(1 2 3 2 4 6 3 6 9)))
  (should (equal (-flatten-n 2 (apply '-table 'list (-repeat 3 '(1 2)))) '((1 1 1) (2 1 1) (1 2 1) (2 2 1) (1 1 2) (2 1 2) (1 2 2) (2 2 2)))))

(ert-deftest -first ()
  (should (equal (-first 'even? '(1 2 3)) 2))
  (should (equal (-first 'even? '(1 3 5)) nil))
  (should (equal (--first (> it 2) '(1 2 3)) 3)))

(ert-deftest -last ()
  (should (equal (-last 'even? '(1 2 3 4 5 6 3 3 3)) 6))
  (should (equal (-last 'even? '(1 3 7 5 9)) nil))
  (should (equal (--last (> (length it) 3) '("a" "looong" "word" "and" "short" "one")) "short")))

(ert-deftest -first-item ()
  (should (equal (-first-item '(1 2 3)) 1))
  (should (equal (-first-item nil) nil)))

(ert-deftest -last-item ()
  (should (equal (-last-item '(1 2 3)) 3))
  (should (equal (-last-item nil) nil)))

(ert-deftest -butlast ()
  (should (equal (-butlast '(1 2 3)) '(1 2)))
  (should (equal (-butlast '(1 2)) '(1)))
  (should (equal (-butlast '(1)) nil))
  (should (equal (-butlast nil) nil)))

(ert-deftest -sort ()
  (should (equal (-sort '< '(3 1 2)) '(1 2 3)))
  (should (equal (-sort '> '(3 1 2)) '(3 2 1)))
  (should (equal (--sort (< it other) '(3 1 2)) '(1 2 3)))
  (should (equal (let ((l '(3 1 2))) (-sort '> l) l) '(3 1 2))))

(ert-deftest -list ()
  (should (equal (-list 1) '(1)))
  (should (equal (-list 1 2 3) '(1 2 3)))
  (-list (should (equal '(1 2 3) '(1 2 3))))
  (-list (should (equal '((1) (2)) '((1) (2))))))

(ert-deftest -tree-map ()
  (should (equal (-tree-map '1+ '(1 (2 3) (4 (5 6) 7))) '(2 (3 4) (5 (6 7) 8))))
  (should (equal (-tree-map '(lambda (x) (cons x (expt 2 x))) '(1 (2 3) 4)) '((1 . 2) ((2 . 4) (3 . 8)) (4 . 16))))
  (should (equal (--tree-map (length it) '("<body>" ("<p>" "text" "</p>") "</body>")) '(6 (3 4 4) 7)))
  (should (equal (--tree-map 1 '(1 2 (3 4) (5 6))) '(1 1 (1 1) (1 1))))
  (should (equal (--tree-map (cdr it) '((1 . 2) (3 . 4) (5 . 6))) '(2 4 6))))

(ert-deftest -tree-reduce ()
  (should (equal (-tree-reduce '+ '(1 (2 3) (4 5))) 15))
  (should (equal (-tree-reduce 'concat '("strings" (" on" " various") ((" levels")))) "strings on various levels"))
  (should (equal (--tree-reduce (cond
                                 ((stringp it) (concat it " " acc))
                                 (t (let ((sn (symbol-name it))) (concat "<" sn ">" acc "</" sn ">"))))
                                '(body (p "some words") (div "more" (b "bold") "words"))) "<body><p>some words</p> <div>more <b>bold</b> words</div></body>")))

(ert-deftest -tree-reduce-from ()
  (should (equal (-tree-reduce-from '+ 1 '(1 (1 1) ((1)))) 8))
  (should (equal (--tree-reduce-from (-concat acc (list it)) nil '(1 (2 3 (4 5)) (6 7))) '((7 6) ((5 4) 3 2) 1))))

(ert-deftest -tree-mapreduce ()
  (should (equal (-tree-mapreduce 'list 'append '(1 (2 (3 4) (5 6)) (7 (8 9)))) '(1 2 3 4 5 6 7 8 9)))
  (should (equal (--tree-mapreduce 1 (+ it acc) '(1 (2 (4 9) (2 1)) (7 (4 3)))) 9))
  (should (equal (--tree-mapreduce 0 (max acc (1+ it)) '(1 (2 (4 9) (2 1)) (7 (4 3)))) 3))
  (should (equal (--tree-mapreduce (-value-to-list it)
                                   (-concat it acc)
                                   '((1 . 2) (3 . 4) (5 (6 7) 8))) '(1 2 3 4 5 6 7 8)))
  (should (equal (--tree-mapreduce (if (-cons-pair? it) (cdr it) it)
                                   (concat it " " acc)
                                   '("foo" (bar . "bar") ((baz . "baz")) "quux" (qwop . "qwop"))) "foo bar baz quux qwop"))
  (should (equal (--tree-mapreduce (if (-cons-pair? it) (list (cdr it)) nil)
                                   (append it acc)
                                   '((elips-mode (foo (bar . booze)) (baz . qux)) (c-mode (foo . bla) (bum . bam)))) '(booze qux bla bam))))

(ert-deftest -tree-mapreduce-from ()
  (should (equal (-tree-mapreduce-from 'identity '* 1 '(1 (2 (3 4) (5 6)) (7 (8 9)))) 362880))
  (should (equal (--tree-mapreduce-from (+ it it) (cons it acc) nil '(1 (2 (4 9) (2 1)) (7 (4 3)))) '(2 (4 (8 18) (4 2)) (14 (8 6)))))
  (should (equal (concat "{" (--tree-mapreduce-from
                              (cond
                               ((-cons-pair? it)
                                (concat (symbol-name (car it)) " -> " (symbol-name (cdr it))))
                               (t (concat (symbol-name it) " : {")))
                              (concat it (unless (or (equal acc "}")
                                                     (equal (substring it (1- (length it))) "{"))
                                           ", ") acc)
                              "}"
                              '((elips-mode (foo (bar . booze)) (baz . qux)) (c-mode (foo . bla) (bum . bam))))) "{elips-mode : {foo : {bar -> booze}, baz -> qux}, c-mode : {foo -> bla, bum -> bam}}")))

(ert-deftest -clone ()
  (should (equal (let* ((a '(1 2 3)) (b (-clone a))) (nreverse a) b) '(1 2 3))))

(ert-deftest -> ()
  (should (equal (-> '(2 3 5)) '(2 3 5)))
  (should (equal (-> '(2 3 5) (append '(8 13))) '(2 3 5 8 13)))
  (should (equal (-> '(2 3 5) (append '(8 13)) (-slice 1 -1)) '(3 5 8)))
  (should (equal (-> 5 square) 25))
  (should (equal (-> 5 (+ 3) square) 64)))

(ert-deftest ->> ()
  (should (equal (->> '(1 2 3) (-map 'square)) '(1 4 9)))
  (should (equal (->> '(1 2 3) (-map 'square) (-remove 'even?)) '(1 9)))
  (should (equal (->> '(1 2 3) (-map 'square) (-reduce '+)) 14))
  (should (equal (->> 5 (- 8)) 3))
  (should (equal (->> 5 (- 3) square) 4)))

(ert-deftest --> ()
  (should (equal (--> "def" (concat "abc" it "ghi")) "abcdefghi"))
  (should (equal (--> "def" (concat "abc" it "ghi") (upcase it)) "ABCDEFGHI"))
  (should (equal (--> "def" (concat "abc" it "ghi") upcase) "ABCDEFGHI")))

(ert-deftest -when-let ()
  (should (equal (-when-let (match-index (string-match "d" "abcd")) (+ match-index 2)) 5))
  (should (equal (--when-let (member :b '(:a :b :c)) (cons :d it)) '(:d :b :c)))
  (should (equal (--when-let (even? 3) (cat it :a)) nil)))

(ert-deftest -when-let* ()
  (should (equal (-when-let* ((x 5) (y 3) (z (+ y 4))) (+ x y z)) 15))
  (should (equal (-when-let* ((x 5) (y nil) (z 7)) (+ x y z)) nil)))

(ert-deftest -if-let ()
  (should (equal (-if-let (match-index (string-match "d" "abc")) (+ match-index 3) 7) 7))
  (should (equal (--if-let (even? 4) it nil) t)))

(ert-deftest -if-let* ()
  (should (equal (-if-let* ((x 5) (y 3) (z 7)) (+ x y z) "foo") 15))
  (should (equal (-if-let* ((x 5) (y nil) (z 7)) (+ x y z) "foo") "foo")))

(ert-deftest -each ()
  (should (equal (let (s) (-each '(1 2 3) (lambda (item) (setq s (cons item s))))) nil))
  (should (equal (let (s) (-each '(1 2 3) (lambda (item) (setq s (cons item s)))) s) '(3 2 1)))
  (should (equal (let (s) (--each '(1 2 3) (setq s (cons it s))) s) '(3 2 1)))
  (should (equal (let (s) (--each (reverse (three-letters)) (setq s (cons it s))) s) '("A" "B" "C"))))

(ert-deftest -each-while ()
  (should (equal (let (s) (-each-while '(2 4 5 6) 'even? (lambda (item) (!cons item s))) s) '(4 2)))
  (should (equal (let (s) (--each-while '(1 2 3 4) (< it 3) (!cons it s)) s) '(2 1))))

(ert-deftest -dotimes ()
  (should (equal (let (s) (-dotimes 3 (lambda (n) (!cons n s))) s) '(2 1 0)))
  (should (equal (let (s) (--dotimes 5 (!cons it s)) s) '(4 3 2 1 0))))

(ert-deftest !cons ()
  (should (equal (let (l) (!cons 5 l) l) '(5)))
  (should (equal (let ((l '(3))) (!cons 5 l) l) '(5 3))))

(ert-deftest !cdr ()
  (should (equal (let ((l '(3))) (!cdr l) l) '()))
  (should (equal (let ((l '(3 5))) (!cdr l) l) '(5))))

