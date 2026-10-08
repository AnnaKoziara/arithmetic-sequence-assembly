global arithmetic_sequence

section .text

; Funkcja: arithmetic_sequence
; Działanie: Obliczenie k-tego wyrazu ciągu arytmetycznego
;            zgodnie ze wzorem: Ak = A0 + k * (A1 - A0).
; Autor: Anna Koziara

; Rejestry argumentów funkcji:
; rdi - wskaźnik na aktualny element tablicy wyrazu A0.
; rsi - wskaźnik na aktualny element tablicy wyrazu A1.
; rdx - wskaźnik na początek tablicy wyrazu obliczanego Ak.
; rcx - liczba elementów tablic.
; r8  - wartość mnożnika k.

; Rejestry pomocnicze:
; r9  - wskaźnik na obliczany element wynikowej tablicy Ak
; oraz przechowanie wartości młodszych bitów wyniku.
; rbx - wartość przeniesienia z dodawania elementów.
; r10 - wartość pożyczki z odejmowania A1[i] - A0[i].
; r11 - przechowanie różnicy A1[i] - A0[i] oraz
; rozszerzony znak przeniesienia.
; rcx - pomocnicze przechowanie licznika iteracji pętli wynikowej.

arithmetic_sequence:
    ; Zachowanie na stosie wartości rejestru.
    push rbx

    ; Przygotowanie rejestrów przed wykonaniem pętli.
    mov r9, rdx                 ; Rdx jest nadpisywany przez operację mul.
    xor rbx, rbx                ; Przeniesienie początkowo wynosi 0.
    xor r10, r10                ; Pożyczka początkowo wynosi 0.

.petla:
    ; Obliczenie różnicy B_i = A1[i] - A0[i] - (pożyczka).
    mov rax, [rsi]              ; Pobranie i-tego elementu liczby A1.
    neg r10                     ; Pobranie pożyczki do flagi przeniesienia.
    sbb rax, [rdi]              ; Odjęcie od A1[i] elementu A0[i] i flagi.
    sbb r10, r10                ; Zapisanie nowej pożyczki (0 lub -1).
    mov r11, rax                ; Zapisanie B_i, aby wykonać mnożenie.

    ; Mnożenie k * B_i z uwzględnieniem znaku mnożnika k.
    mul r8                      ; Mnożenie bez znaku.
    test r8, r8                 ; Sprawdzenie znaku mnożnika k.
    jns .poMnozeniu             ; Dla k >= 0 wynik jest poprawny.
    sub rdx, r11                ; Odjęcie nadmiaru z wyniku dla ujemnego k.

.poMnozeniu:
    ; Dodawanie A0[i] + (B_i * k) + (przeniesienie z poprzedniej iteracji).
    mov r11, rbx                ; Pobranie wartości przeniesienia.
    sar r11, 63                 ; Rozszerzenie znaku przeniesienia.

    add rax, rbx                ; Dodanie młodszej części przeniesienia.
    adc rdx, r11                ; Dodanie starszej części przeniesienia.

    add rax, [rdi]              ; Dodanie do wyniku wartości A0[i].
    adc rdx, 0                  ; Dodanie przeniesienia do starszej części.

    ; Zapisanie wartości elementu Ak[i].
    mov [r9], rax               ; Zapisanie wyniku w tablicy Ak.
    mov rbx, rdx                ; Zapisanie starszej części do przeniesienia.

    ; Przejście do kolejnych elementów tablic.
    add rdi, 8                  ; Przesunięcie wskaźnika A0.
    add rsi, 8                  ; Przesunięcie wskaźnika A1.
    add r9, 8                   ; Przesunięcie wskaźnika Ak.

    dec rcx                     ; Zmniejszenie licznika elementów.
    jnz .petla                  ; Ponowne wykonanie pętli.

.obslugaOstatnichBitow:
    ; Pobranie ostatnich elementów tablic i wyznaczenie ich znaków.
    mov rdi, [rdi - 8]          ; Pobranie ostatniego elementu tablicy A0.
    sar rdi, 63                 ; Rozszerzenie znaku wyrazu A0.
    mov rsi, [rsi - 8]          ; Pobranie ostatniego elementu tablicy A1.
    sar rsi, 63                 ; Rozszerzenie znaku wyrazu A1.

    ; Ustawienie licznika pętli obliczającej ostatnie 128 bitów.
    mov ecx, 2                  ; Licznik pętli wynikowej.

.petlaWyniku:
    ; Obliczenia wykorzystujące rozszerzone bity znaków.
    mov rax, rsi                ; Pobranie znaku A1.
    neg r10                     ; Pobranie pożyczki do flagi przeniesienia.
    sbb rax, rdi                ; Odjęcie od znaku A1 znaku A0 i pożyczki.
    sbb r10, r10                ; Zapisanie nowej pożyczki.
    mov r11, rax                ; Zapisanie B_i, aby wykonać mnożenie.

    mul r8                      ; Mnożenie bez znaku.
    test r8, r8                 ; Sprawdzenie znaku mnożnika k.
    jns .poMnozeniuWynikowym    ; Dla k >= 0 wynik mnożenia jest poprawny.
    sub rdx, r11                ; Odjęcie nadmiaru z wyniku dla ujemnego k.

.poMnozeniuWynikowym:
    mov r11, rbx                ; Pobranie wartości przeniesienia.
    sar r11, 63                 ; Rozszerzenie znaku przeniesienia.
    add rax, rbx                ; Dodanie młodszej części przeniesienia.
    adc rdx, r11                ; Dodanie starszej części przeniesienia.
    
    add rax, rdi                ; Dodanie znaku A0 do wyniku.
    adc rdx, 0                  ; Dodanie ewentualnego przeniesienia.

    dec ecx                     ; Zmniejszenie wartości licznika pętli.
    jz .koniec                  ; W drugiej iteracji wyjście z pętli.

    ; Zapisanie wyniku z pierwszej iteracji.
    mov r9, rax                 ; Zapisanie młodszych 64 bitów w r9.
    mov rbx, rdx                ; Starsze bity stają się przeniesieniem.
    jmp .petlaWyniku            ; Wykonanie pętli drugi raz.

.koniec:
    ; Umieszczenie ostatnich 128 bitów w rejestrach wyniku.
    mov rdx, rax                ; Przypisanie starszych 64 bitów.
    mov rax, r9                 ; Przypisanie młodszych 64 bitów z r9.

    pop rbx                     ; Przywrócenie początkowej wartości rbx.
    ret                         ; Powrót z funkcji.