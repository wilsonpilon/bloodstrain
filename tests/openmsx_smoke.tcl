# SPDX-License-Identifier: GPL-3.0-only
set output $::env(BLOODSTRAIN_SMOKE_OUTPUT)
set save_settings_on_exit false
set throttle on

proc result {message} {
    set file [open [file join $::output result.txt] w]
    puts $file $message
    close $file
    puts $message
}

proc title_test {} {
    if {[catch {
        set r0 [debug read "VDP regs" 0]
        set r1 [debug read "VDP regs" 1]
        if {($r0 & 14) != 6 || ($r1 & 24) != 0 || ($r1 & 64) == 0} {
            error "A abertura nao esta em SCREEN 5: R0=$r0 R1=$r1 PC=[reg PC] SP=[reg SP]"
        }
        if {[debug read VRAM 0] != 102 || [debug read VRAM 19456] != 68} {
            error "As faixas coloridas da abertura nao estao na VRAM"
        }
        # Allow a real rendered frame even if the user's emulator was in turbo.
        after realtime 1 capture_title
    } message]} {
        result "FAIL: $message"
        quit
    }
}

proc capture_title {} {
    screenshot -raw [file join $::output title.png]
    after realtime 1 {keymatrixdown 7 4}
    after realtime 1.2 {keymatrixup 7 4}
    after realtime 3 {type_via_keybuf "ECHO RETURN_OK\r"}
    after realtime 5 dos_test
}

proc dos_test {} {
    if {[catch {
        set r0 [debug read "VDP regs" 0]
        set r1 [debug read "VDP regs" 1]
        if {($r0 & 14) != 0 || ($r1 & 24) != 16} {
            error "ESC nao restaurou SCREEN 0: R0=$r0 R1=$r1"
        }
        screenshot -raw [file join $::output dos.png]
        set screen [debug read_block VRAM 0 960]
        if {[string first "RETURN_OK" $screen] < 0} {
            error "O DOS nao executou o comando ECHO apos a saida"
        }
        result "PASS: SCREEN 5, ESC, SCREEN 0 e comando ECHO no DOS"
    } message]} {
        result "FAIL: $message"
    }
    quit
}

result "PENDING"
after time 25 title_test
after realtime 50 {
    result "FAIL: timeout no emulador"
    quit
}
