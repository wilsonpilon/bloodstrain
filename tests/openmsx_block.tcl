# SPDX-License-Identifier: GPL-3.0-only
set output $::env(BLOODSTRAIN_SMOKE_OUTPUT)
set save_settings_on_exit false
set throttle on
set speed 100
set file [open $::env(BLOODSTRAIN_SMOKE_MAP) r]
set map [read $file]
close $file
foreach symbol {g_BlockRoom g_BlockX g_BlockY g_VDP_REGSAV} {
    if {![regexp [format {(?m)^\s*([0-9A-Fa-f]+)\s+_%s\s} $symbol] $map dummy address]} {
        error "Simbolo ausente: $symbol"
    }
    scan $address %x address
    set addr($symbol) $address
}
proc value {name} {
    if {[info exists ::world_ram]} {
        return [debug read $::world_ram [expr {$::world_base+($::addr($name)&16383)}]]
    }
    return [debug read memory $::addr($name)]
}
proc pin_world_ram {} {
    set page [expr {$::addr(g_BlockRoom)>>14}]
    set header [debug read_block memory [expr {$page*16384}] 256]
    foreach ram {{Main RAM} {512k External RAM}} {
        set segment [debug read "$ram regs" $page]
        set base [expr {($segment % ([debug size $ram]/16384))*16384}]
        if {[debug read_block $ram $base 256] eq $header &&
            [debug read $ram [expr {$base+($::addr(g_BlockRoom)&16383)}]] == 1} {
            set ::world_ram $ram
            set ::world_base $base
            return
        }
    }
    error "RAM fisica do mapa nao identificada"
}
proc result {message} {
    set f [open [file join $::output block-result.txt] w]
    puts $f $message
    close $f
    puts $message
}
proc later {script} {
    if {[catch {uplevel #0 $script} message]} {
        result "FAIL: $message"
        screenshot -raw [file join $::output block-failure.png]
        quit
    }
}
set file [open [file join $::env(BLOODSTRAIN_SMOKE_ART) TITLE.SC5] rb]
set title [read $file 20480]
close $file
proc wait_title {} {
    if {[debug read_block VRAM 0 20480] eq $::title &&
        ([debug read "VDP regs" 1] & 64) != 0} {
        after time 0.6 {keymatrixdown 4 4}
        after time 0.8 {keymatrixup 4 4}
        after time 1 {later wait_world}
    } else { after time 0.1 {later wait_title} }
}
proc wait_world {} {
    if {[value g_BlockRoom] == 1 && [value g_BlockX] == 128 &&
        [value g_BlockY] == 88 && ([debug read "VDP regs" 1] & 64) != 0 &&
        [debug read "VDP regs" 6] == 15} {
        pin_world_ram
        set file [open [file join $::env(BLOODSTRAIN_SMOKE_ART) protagonist.spr] rb]
        set sprite [read $file]
        close $file
        set pattern_bytes [expr {[string length $sprite]-128}]
        if {[debug read_block VRAM 0x7800 $pattern_bytes] ne [string range $sprite 0 [expr {$pattern_bytes-1}]] ||
            [debug read_block VRAM 0x7400 128] ne [string range $sprite $pattern_bytes end]} {
            error "Padroes/cores da protagonista diferem da arte exportada"
        }
        foreach reg {8 9 10} {
            if {[debug read "PSG regs" $reg] != 0} { error "PSG ativo no mapa" }
        }
        if {$::env(BLOODSTRAIN_SMOKE_VIDEO_HZ) != 0} {
            set r9 [expr {([debug read "VDP regs" 9]&253) |
                ($::env(BLOODSTRAIN_SMOKE_VIDEO_HZ)==50 ? 2 : 0)}]
            debug write "VDP regs" 9 $r9
            debug write $::world_ram [expr {$::world_base+($::addr(g_VDP_REGSAV)&16383)+9}] $r9
        }
        after time 0.2 {later next_action}
    } else { after time 0.1 {later wait_world} }
}
# Walk actual paths, no teleporting or memory writes to game state.
# op: move axis target row mask; room expected; shot name; hold row mask time;
# check axis min max; exit (map -> title -> DOS).
set actions {
    {shot center}
    {hold 8 32 0.8} {check g_BlockY 75 77}
    {move g_BlockY 88 8 64}
    {move g_BlockX 72 8 16} {move g_BlockY 68 8 32}
    {room 3} {shot market}
    {move g_BlockY 144 8 32} {move g_BlockX 72 8 128}
    {move g_BlockY 180 8 64} {room 1}
    {move g_BlockX 164 8 128} {move g_BlockY 154 8 64}
    {room 4} {shot pharmacy}
    {hold 8 16 0.7} {check g_BlockX 106 110}
    {move g_BlockX 168 8 128} {move g_BlockY 28 8 32}
    {room 1}
    {move g_BlockY 120 8 32} {move g_BlockX 250 8 128}
    {room 2} {shot east}
    {move g_BlockY 120 8 64} {move g_BlockX 250 8 128}
    {hold 8 128 0.2} {check g_BlockX 250 251}
    {move g_BlockX 152 8 16} {move g_BlockY 4 8 32}
    {hold 8 32 0.2} {check g_BlockY 4 5}
    {move g_BlockY 88 8 64} {move g_BlockX 40 8 16}
    {move g_BlockY 56 8 32}
    {move g_BlockX 28 8 16} {room 3} {shot market-side}
    {move g_BlockX 234 8 128} {room 2}
    {move g_BlockY 88 8 64} {move g_BlockX 4 8 16}
    {room 1} {move g_BlockY 120 8 64}
    {move g_BlockX 4 8 16} {room 0} {shot west}
    {move g_BlockY 120 8 64} {move g_BlockX 4 8 16}
    {hold 8 16 0.3} {check g_BlockX 4 4}
    {move g_BlockX 80 8 128} {move g_BlockY 144 8 64}
    {hold 8 64 0.6} {check g_BlockY 148 151}
    {move g_BlockY 120 8 32}
    {gait} {check g_BlockX 155 166} {idle}
    {move g_BlockX 250 8 128} {room 1}
    {exit}
}
set pending {}
set deadline 0
proc next_action {} {
    if {![llength $::actions]} { error "Sequencia de teste vazia" }
    set a [lindex $::actions 0]
    set ::actions [lrange $::actions 1 end]
    set op [lindex $a 0]
    set log [open [file join $::output block-actions.txt] a]
    puts $log "BLOCK $a: room=[value g_BlockRoom] x=[value g_BlockX] y=[value g_BlockY]"
    close $log
    if {$op eq "gait"} {
        set ::gait_frames {}
        set ::gait_arms {}
        keymatrixdown 8 128
        set ::gait_until [expr {[machine_info time]+0.8}]
        sample_gait
        return
    } elseif {$op eq "idle"} {
        set ::idle_sprite [debug read_block VRAM 0x7600 32]
        after time 0.15 {later {
            if {[debug read_block VRAM 0x7600 32] ne $::idle_sprite} {
                error "Sprite continuou animando sem movimento"
            }
            next_action
        }}
        return
    } elseif {$op eq "shot"} {
        for {set line 0} {$line<212} {incr line} {
            set count 0
            for {set sprite 0} {$sprite<8} {incr sprite} {
                set y [debug read VRAM [expr {0x7600+$sprite*4}]]
                if {$y>216} {set y [expr {$y-256}]}
                if {$line>$y && $line<=$y+16} {incr count}
            }
            if {$count>4} {error "Protagonista excedeu quatro sprites na linha $line"}
        }
        screenshot -raw [file join $::output "block-[lindex $a 1].png"]
    } elseif {$op eq "check"} {
        set n [value [lindex $a 1]]
        if {$n < [lindex $a 2] || $n > [lindex $a 3]} {
            error "Colisao $a: valor=$n"
        }
        proc sample_gait {} {
            set patterns {}
            for {set i 0} {$i<8} {incr i} {
                lappend patterns [debug read VRAM [expr {0x7602+$i*4}]]
            }
            dict set ::gait_frames $patterns 1
            dict set ::gait_arms [debug read VRAM 0x760A] 1
            if {[machine_info time] >= $::gait_until} {
                keymatrixup 8 128
                if {[dict size $::gait_frames]<3} {error "Caminhada nao exibiu tres poses distintas"}
                if {[dict size $::gait_arms]<3} {error "Bracos nao exibiram tres poses distintas"}
                after time 0.1 {later next_action}
            } else {after time 0.02 {later sample_gait}}
        }
    } elseif {$op eq "hold"} {
        lassign $a op row mask duration
        keymatrixdown $row $mask
        after time $duration [list keymatrixup $row $mask]
        after time [expr {$duration+0.1}] {later next_action}
        return
    } elseif {$op eq "exit"} {
        keymatrixdown 7 4
        after time 0.2 {keymatrixup 7 4}
        after time 0.5 {later return_title}
        return
    } else {
        set ::pending $a
        set ::deadline [expr {[machine_info time]+8}]
        if {$op eq "move"} {
            lassign $a op axis target row mask
            set ::old_room [value g_BlockRoom]
            set ::start [value $axis]
            keymatrixdown $row $mask
        }
        poll_action
        return
    }
    after time 0.05 {later next_action}
}
proc poll_action {} {
    set a $::pending
    if {[machine_info time] > $::deadline} {
        error "Timeout $a: room=[value g_BlockRoom] x=[value g_BlockX] y=[value g_BlockY]"
    }
    if {[lindex $a 0] eq "move"} {
        lassign $a op axis target row mask
        set n [value $axis]
        if {[value g_BlockRoom] != $::old_room ||
            ($target >= $::start && $n >= $target) ||
            ($target < $::start && $n <= $target)} {
            keymatrixup $row $mask
            after time 0.1 {later next_action}
            return
        }
    } else {
        if {[value g_BlockRoom] == [lindex $a 1] &&
            ([debug read "VDP regs" 1] & 64) != 0} {
            after time 0.2 {later next_action}
            return
        }
    }
    after time 0.01 {later poll_action}
}
proc return_title {} {
    if {[debug read_block VRAM 0 20480] eq $::title &&
        ([debug read "VDP regs" 1] & 64) != 0} {
        after time 0.5 {keymatrixdown 7 4}
        after time 0.7 {keymatrixup 7 4}
        after time 1 {later wait_dos}
    } else {after time 0.1 {later return_title}}
}
proc wait_dos {} {
    if {([debug read "VDP regs" 0] & 14) == 0 &&
        ([debug read "VDP regs" 1] & 88) == 80 &&
        [string first {B:\>} [debug read_block VRAM 0 960]] >= 0} {
        after time 0.5 {type_via_keybuf "ECHO BLOCK_OK\r"}
        after time 5 {
            later {
                if {[string first "BLOCK_OK" [debug read_block VRAM 0 960]] < 0} {
                    error "DOS nao respondeu: PC=[reg PC] SP=[reg SP] CODE=[binary encode hex [debug read_block memory [reg PC] 16]] STACK=[binary encode hex [debug read_block memory [reg SP] 32]] VDP=[binary encode hex [debug read_block {VDP regs} 0 16]]"
                }
                screenshot -raw [file join $::output block-dos.png]
                result "PASS: cinco salas, quatro direcoes, colisoes, portas principal/lateral, retornos, limites, titulo e DOS"
                quit
            }
        }
    } else {after time 0.1 {later wait_dos}}
}
result PENDING
set file [open [file join $::output block-actions.txt] w]
close $file
after time 2 {later wait_title}
after realtime 180 {
    result "FAIL: timeout global do mapa"
    screenshot -raw [file join $::output block-failure.png]
    quit
}
