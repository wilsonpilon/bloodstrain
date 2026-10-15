# SPDX-License-Identifier: GPL-3.0-only
set output $::env(BLOODSTRAIN_SMOKE_OUTPUT)
set package $::env(BLOODSTRAIN_SMOKE_PACKAGE)
set save_settings_on_exit false
set throttle on
set speed 100
set sequence {TITLE INTRO1 CARD1 INTRO2 CARD2 INTRO3 CARD3 INTRO4 CARD4 INTRO5 CARD5 INTRO6 CARD6 TITLE INTRO1 TITLE INTRO1 CARD1}
set step 0
set transition_start 0
set max_transition 0
set audio 1
if {[info exists ::env(BLOODSTRAIN_SMOKE_AUDIO)]} {
    set audio $::env(BLOODSTRAIN_SMOKE_AUDIO)
}
set music_seconds 0
if {[info exists ::env(BLOODSTRAIN_SMOKE_MUSIC_SECONDS)]} {
    set music_seconds $::env(BLOODSTRAIN_SMOKE_MUSIC_SECONDS)
}
set trace [open [file join $output trace.txt] w]
close $trace
set file [open $::env(BLOODSTRAIN_SMOKE_PALETTE) rb]
set expected_palette [read $file]
close $file
set loading_captured 0
set music_samples 0
set music_changes 0
set last_psg ""
set fm_debug ""
set scc_debug ""
foreach device [debug list] {
    if {[string match "*FMPAC regs" $device]} { set fm_debug $device }
    if {[string match "* SCC SCC" $device]} { set scc_debug $device }
}
set file [open $::env(BLOODSTRAIN_SMOKE_MAP) r]
set map [read $file]
close $file
if {![regexp {(?m)^\s*([0-9A-Fa-f]+)\s+_g_DOS_VarTable\s} $map dummy address]} {
    error "Simbolo do mapper ausente no mapa de link"
}
scan $address %x mapper_pointer
if {![regexp {(?m)^\s*([0-9A-Fa-f]+)\s+_g_VDP_REGSAV\s} $map dummy address]} {
    error "Backup dos registros VDP ausente no mapa"
}
scan $address %x vdp_backup
proc mapper_free {} {
    if {[info exists ::mapper_physical]} {
        return [debug read $::mapper_ram $::mapper_physical]
    }
    if {![info exists ::mapper_table]} {
        set low [debug read memory $::mapper_pointer]
        set high [debug read memory [expr {$::mapper_pointer+1}]]
        set ::mapper_table [expr {$low+256*$high}]
    }
    # The BIOS temporarily maps a different page 3 during the music interrupt.
    # Pin the DOS table's physical address while foreground loading is active.
    if {[debug read memory [expr {$::mapper_table+1}]] != 32} {
        unset ::mapper_table
        return -1
    }
    set header [debug read_block memory $::mapper_table 16]
    foreach ram {{Main RAM} {512k External RAM}} {
        set segment [debug read "$ram regs" 3]
        set offset [expr {($segment % ([debug size $ram]/16384))*16384+($::mapper_table & 16383)}]
        if {[debug read_block $ram $offset 16] eq $header} {
            set ::mapper_ram $ram
            set ::mapper_physical [expr {$offset+2}]
            return [debug read $ram $::mapper_physical]
        }
    }
    error "Tabela DOS nao localizada na RAM fisica"
}
proc trace_message {message} {
    set file [open [file join $::output trace.txt] a]
    puts $file $message
    close $file
}
foreach name {TITLE INTRO1 INTRO2 INTRO3 INTRO4 INTRO5 INTRO6} {
    set file [open [file join $::env(BLOODSTRAIN_SMOKE_ART) "$name.SC5"] rb]
    set expected($name) [read $file 20480]
    close $file
}

proc result {message} {
    set file [open [file join $::output result.txt] w]
    puts $file $message
    close $file
    puts $message
}

proc press {row mask} {
    trace_message "Key row=$row mask=$mask PC=[reg PC]"
    keymatrixdown $row $mask
    after time 0.4 [list keymatrixup $row $mask]
}

proc await_frame {} {
    if {[catch {check_frame} message]} {
        result "FAIL: $message"
        quit
    }
}

proc check_frame {} {
    if {!$::loading_captured && [debug read VRAM 18624] != 0 &&
        ([debug read "VDP regs" 1] & 64) != 0 &&
        [debug read VRAM 0] == 0} {
        if {[mapper_free] < 0} {
            after time 0.02 await_frame
            return
        }
        screenshot -raw [file join $::output loading.png]
        set ::loading_captured 1
        if {[info exists ::env(BLOODSTRAIN_SMOKE_VIDEO_HZ)] &&
            $::env(BLOODSTRAIN_SMOKE_VIDEO_HZ) != 0} {
            set r9 [expr {([debug read "VDP regs" 9] & 253) |
                ($::env(BLOODSTRAIN_SMOKE_VIDEO_HZ) == 50 ? 2 : 0)}]
            debug write "VDP regs" 9 $r9
            debug write memory [expr {$::vdp_backup+9}] $r9
        }
        set ::original_hook [debug read_block memory 0xFD9F 5]
        foreach {x bit} {6 1 86 2 166 4} {
            # The descending part of each green tick crosses (x+4, 111).
            set pixel [debug read VRAM [expr {111*128+($x+4)/2}]]
            if {($pixel >> 4 == 9) != (($::audio & $bit) != 0)} {
                error "Indicador de audio incorreto: bit=$bit pixel=$pixel"
            }
        }
        foreach reg {8 9 10} {
            if {[debug read "PSG regs" $reg] != 0} { error "PSG tocou durante carga" }
        }
        if {$::audio & 2} {
            for {set reg 0x20} {$reg <= 0x28} {incr reg} {
                if {[debug read $::fm_debug $reg] & 16} { error "FM tocou durante carga" }
            }
        }
        if {($::audio & 4) && [debug read $::scc_debug 0xAF] != 0} {
            error "SCC tocou durante carga"
        }
    }
    set name [lindex $::sequence $::step]
    set r0 [debug read "VDP regs" 0]
    set r1 [debug read "VDP regs" 1]
    set r9 [debug read "VDP regs" 9]
    set art [debug read_block VRAM 0 20480]
    set heading [debug read_block VRAM 20992 896]
    if {[string match "CARD*" $name]} {
        set number [string index $name 4]
        set ready [expr {[debug read VRAM 0] == (7+$number)*17 &&
            [string trim [debug read_block VRAM 9984 10240] "\x00"] ne ""}]
    } else {
        set ready [expr {$art eq $::expected($name) &&
            [string trim $heading "\x00"] ne ""}]
    }
    if {($r0 & 14) == 6 && ($r1 & 24) == 0 && ($r1 & 64) != 0 &&
        ($r9 & 128) != 0 && $ready} {
        if {[debug read_block "VDP palette" 0 32] ne $::expected_palette} {
            result "FAIL: a paleta do VDP difere das 16 cores da arte"
            quit
            return
        }
        if {$::step > 0} {
            set elapsed [expr {[machine_info time]-$::transition_start}]
            if {$elapsed > $::max_transition} { set ::max_transition $elapsed }
            trace_message "Transition $name: $elapsed seconds"
            if {$elapsed > 1.5} {
                result "FAIL: transicao $name excedeu 1.5 segundos: $elapsed"
                quit
                return
            }
        }
        after time 0.45 capture_frame
    } else {
        after time 0.02 await_frame
    }
}

proc capture_frame {} {
    set name [lindex $::sequence $::step]
    trace_message "Frame $::step: $name time=[machine_info time] PC=[reg PC]"
    if {$::step == 0} {
        set ::free_cached [mapper_free]
        trace_message "Mapper before: free=$::free_cached physical=$::mapper_physical"
        # No file opens/reads are allowed after preload, including during replay.
        set ::disk_guard [debug set_bp 5 {([reg C] == 0x43 || [reg C] == 0x48)} {
            result "FAIL: acesso ao disco depois da precarga"
            quit
        }]
        set ::title_time [machine_info time]
        set ::actual_hz [expr {([debug read "VDP regs" 9] & 2) ? 50 : 60}]
        sample_music
        if {$::music_seconds > 0} {
            soundlog start [file join $::output intro.wav]
            after time $::music_seconds {soundlog stop; advance_frame}
            return
        }
    }
    advance_frame
}

proc sample_music {} {
    if {[catch {
        set psg [debug read_block "PSG regs" 0 11]
        if {$psg ne $::last_psg} { incr ::music_changes }
        set ::last_psg $psg
        incr ::music_samples
        if {([debug read "PSG regs" 8] & 15) == 0} {
            error "PSG sem baixo durante a musica"
        }
        if {$::audio & 2} {
            set active 0
            if {$::fm_debug ne ""} {
                for {set reg 0x20} {$reg <= 0x24} {incr reg} {
                    set active [expr {$active | ([debug read $::fm_debug $reg] & 16)}]
                }
            }
            if {!$active} {
                error "Camada FM inativa"
            }
        }
        if {$::audio & 4} {
            if {$::scc_debug eq "" || ([debug read $::scc_debug 0xAF] & 7) != 7} {
                error "Camada SCC inativa"
            }
        }
        set ::music_timer [after time 0.1 sample_music]
    } message]} {
        result "FAIL: $message"
        quit
    }
}

proc advance_frame {} {
    set name [lindex $::sequence $::step]
    screenshot -raw [file join $::output "[string tolower $name].png"]
    if {$::step == 17} {
        # ESC must also work from inside the intro, not just the title.
        after cancel $::music_timer
        debug remove_bp $::disk_guard
        press 7 4
        after time 0.5 await_dos
        return
    }
    if {$::step == 14} {
        press 5 1
    } elseif {$::step % 2} {
        press 7 128
    } else {
        press 8 1
    }
    set ::transition_start [machine_info time]
    incr ::step
    after time 0.02 await_frame
}

proc await_dos {} {
    set r0 [debug read "VDP regs" 0]
    set r1 [debug read "VDP regs" 1]
    if {($r0 & 14) == 0 && ($r1 & 24) == 16} {
        foreach reg {8 9 10} {
            if {[debug read "PSG regs" $reg] != 0} {
                result "FAIL: PSG nao silenciado ao sair"
                quit
                return
            }
        }
        if {$::audio & 2} {
            for {set reg 0x20} {$reg <= 0x28} {incr reg} {
                if {[debug read $::fm_debug $reg] & 16} {
                    result "FAIL: FM nao silenciado ao sair"
                    quit
                    return
                }
            }
        }
        if {($::audio & 4) && [debug read $::scc_debug 0xAF] != 0} {
            result "FAIL: SCC nao silenciado ao sair"
            quit
            return
        }
        after time 1 {type_via_keybuf "ECHO RETURN_OK\r"}
        after time 3 dos_test
    } else {
        after time 0.1 await_dos
    }
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
        if {[mapper_free] != $::free_cached + 14} {
            error "Cache mapper: antes=$::free_cached depois=[mapper_free] tabela=$::mapper_table (esperado +14)"
        }
        if {$::music_samples < 20 || $::music_changes < 10} {
            error "Musica nao progrediu: samples=$::music_samples changes=$::music_changes"
        }
        if {!$::loading_captured} { error "Painel de carga nao capturado" }
        if {[debug read_block memory 0xFD9F 5] ne $::original_hook} {
            error "Hook H_TIMI nao restaurado"
        }
        trace_message "Audio mask=$::audio samples=$::music_samples changes=$::music_changes"
        trace_message "Video Hz=$::actual_hz"
        trace_message "Max transition: $::max_transition seconds"
        result "PASS: ZX0/mapper, imagens/cartoes/paleta, cache sem disco, 14 segmentos liberados, transicoes <=1.5s, audio $::audio ativo e silenciado na saida, painel, hook, replay, S, ESC e DOS"
    } message]} {
        result "FAIL: $message"
    }
    quit
}

result "PENDING"
after time 2 await_frame
after realtime 180 {
    screenshot -raw [file join $::output failure.png]
    result "FAIL: timeout na etapa $::step ([lindex $::sequence $::step]); PC=[reg PC]; SP=[reg SP]; VRAM0=[debug read VRAM 0]; R1=[debug read {VDP regs} 1]"
    quit
}
