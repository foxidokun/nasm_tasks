section .text

;; ####################################
;; # Format Char                      #
;; ####################################
;; # Args:                            #
;; # rdi -- pointer to str            #
;; # Return: rcx -- strlen            #
;; # Destroys: al (rdi)               #
;; ####################################
strlen:
	xor	rcx,rcx
	xor	al, al
	not rcx ; rcx = -1u
    repne scasb

    ; rcx = (-rcx-1) - 1 = strlen
	not	rcx
	dec	rcx
ret
