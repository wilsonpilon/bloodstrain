// SPDX-License-Identifier: GPL-3.0-only
// Original pixel illustrations. Node built-ins only; no external art or fonts.
"use strict";
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const { execFileSync } = require("child_process");
const assert = require("assert");
const root = path.resolve(__dirname, "..", "..", "..");
const out = path.join(root, "assets", "art", "export");
const check = process.argv.includes("--check");
const W = 256, H = 212;
const palette = [
    [0,0,0], [1,1,2], [2,1,3], [2,3,4],
    [1,3,3], [2,4,3], [4,5,3], [7,7,5],
    [4,1,1], [6,2,1], [7,4,2], [7,6,3],
    [4,2,3], [6,4,3], [5,6,6], [7,7,7]
];
const scenes = [
    ["INTRO1.SC5", "01 - LONGE DE CASA",
        "Sudeste Asiatico, 1982-1984.",
        "Uma viagem termina com uma mordida."],
    ["INTRO2.SC5", "02 - A MORDIDA",
        "O animal foge. Parece so um acidente.",
        "A ferida viaja de volta."],
    ["INTRO3.SC5", "03 - VOO DE VOLTA",
        "A febre toma o voo. De Congonhas,",
        "ela segue ao hospital na Mooca."],
    ["INTRO4.SC5", "04 - ULTIMO PLANTAO",
        "A paciente morre. Nas obras, um erro",
        "leva os residuos para a agua."],
    ["INTRO5.SC5", "05 - AGUA ESCURA",
        "A agua chega as casas. Febre. Violencia.",
        "O bairro comeca a mudar."],
    ["INTRO6.SC5", "06 - ANTES DE ANOITECER",
        "Voce so quer ir ao mercado.",
        "A madrugada pode esperar. Eles, nao."]
];
const alphabet = {
    A:["01110","10001","10001","11111","10001","10001","10001"],
    B:["11110","10001","10001","11110","10001","10001","11110"],
    C:["01111","10000","10000","10000","10000","10000","01111"],
    D:["11110","10001","10001","10001","10001","10001","11110"],
    E:["11111","10000","10000","11110","10000","10000","11111"],
    F:["11111","10000","10000","11110","10000","10000","10000"],
    G:["01111","10000","10000","10111","10001","10001","01111"],
    H:["10001","10001","10001","11111","10001","10001","10001"],
    I:["111","010","010","010","010","010","111"],
    J:["00111","00010","00010","00010","00010","10010","01100"],
    K:["10001","10010","10100","11000","10100","10010","10001"],
    L:["10000","10000","10000","10000","10000","10000","11111"],
    M:["10001","11011","10101","10101","10001","10001","10001"],
    N:["10001","11001","10101","10011","10001","10001","10001"],
    O:["01110","10001","10001","10001","10001","10001","01110"],
    P:["11110","10001","10001","11110","10000","10000","10000"],
    Q:["01110","10001","10001","10001","10101","10010","01101"],
    R:["11110","10001","10001","11110","10100","10010","10001"],
    S:["01111","10000","10000","01110","00001","00001","11110"],
    T:["11111","00100","00100","00100","00100","00100","00100"],
    U:["10001","10001","10001","10001","10001","10001","01110"],
    V:["10001","10001","10001","10001","10001","01010","00100"],
    W:["10001","10001","10001","10101","10101","10101","01010"],
    X:["10001","10001","01010","00100","01010","10001","10001"],
    Y:["10001","10001","01010","00100","00100","00100","00100"],
    Z:["11111","00001","00010","00100","01000","10000","11111"],
    "0":["01110","10001","10011","10101","11001","10001","01110"],
    "1":["00100","01100","00100","00100","00100","00100","01110"],
    "2":["01110","10001","00001","00010","00100","01000","11111"],
    "3":["11110","00001","00001","01110","00001","00001","11110"],
    "4":["00010","00110","01010","10010","11111","00010","00010"],
    "5":["11111","10000","10000","11110","00001","00001","11110"],
    "6":["01110","10000","10000","11110","10001","10001","01110"],
    "7":["11111","00001","00010","00100","01000","01000","01000"],
    "8":["01110","10001","10001","01110","10001","10001","01110"],
    "9":["01110","10001","10001","01111","00001","00001","01110"],
    "-":["00000","00000","00000","11111","00000","00000","00000"],
    ".":["00000","00000","00000","00000","00000","00110","00110"],
    ",":["00000","00000","00000","00000","00110","00100","01000"],
    ":":["00000","00110","00110","00000","00110","00110","00000"],
    "/":["00001","00010","00010","00100","01000","01000","10000"],
    "!":["00100","00100","00100","00100","00100","00000","00100"],
    " ":["00000","00000","00000","00000","00000","00000","00000"]
};
let image;
function pixel(x,y,c) {
    x = Math.round(x); y = Math.round(y);
    if (x >= 0 && x < W && y >= 0 && y < H) image[y*W+x] = c;
}
function rect(x,y,w,h,c,d=c) {
    for (let j=Math.max(0,Math.round(y)); j<Math.min(H,y+h); j++)
        for (let i=Math.max(0,Math.round(x)); i<Math.min(W,x+w); i++)
            pixel(i,j,(i+j)%2 ? c : d);
}
function ellipse(x,y,rx,ry,c,d=c) {
    for (let j=Math.floor(y-ry); j<=y+ry; j++)
        for (let i=Math.floor(x-rx); i<=x+rx; i++)
            if (((i-x)/rx)**2+((j-y)/ry)**2 <= 1)
                pixel(i,j,(i+j)%2 ? c : d);
}
function poly(points,c,d=c) {
    const min = Math.max(0,Math.floor(Math.min(...points.map(p=>p[1]))));
    const max = Math.min(H-1,Math.ceil(Math.max(...points.map(p=>p[1]))));
    for (let y=min; y<=max; y++) {
        const crosses = [];
        for (let i=0; i<points.length; i++) {
            const a=points[i], b=points[(i+1)%points.length];
            if ((a[1]<=y && b[1]>y)||(b[1]<=y && a[1]>y))
                crosses.push(a[0]+(y-a[1])*(b[0]-a[0])/(b[1]-a[1]));
        }
        crosses.sort((a,b)=>a-b);
        for (let i=0; i<crosses.length; i+=2)
            for (let x=Math.ceil(crosses[i]); x<crosses[i+1]; x++)
                pixel(x,y,(x+y)%2 ? c : d);
    }
}
function line(x0,y0,x1,y1,c,width=1) {
    const steps = Math.max(Math.abs(x1-x0),Math.abs(y1-y0),1);
    for (let i=0;i<=steps;i++) {
        const x=x0+(x1-x0)*i/steps, y=y0+(y1-y0)*i/steps;
        if (width===1) pixel(x,y,c);
        else ellipse(x,y,width/2,width/2,c);
    }
}
function text(str,x,y,c,scale=1,fixed=false) {
    for (const ch of str.toUpperCase()) {
        const glyph=alphabet[ch];
        assert(glyph,`Unsupported glyph: ${ch}`);
        glyph.forEach((row,j)=>[...row].forEach((v,i)=>{
            if(v==="1") rect(x+i*scale,y+j*scale,scale,scale,c);
        }));
        x+=(fixed ? 6 : glyph[0].length+1)*scale;
    }
}
function palm(x,y,s) {
    line(x,y,x+7*s,y-57*s,8,4*s);
    line(x-1,y,x+5*s,y-57*s,11);
    const cx=x+7*s, cy=y-57*s;
    for(const [dx,dy] of [[-34,9],[-25,-13],[-9,-23],[20,-17],[36,3],[27,19]]) {
        poly([[cx,cy],[cx+dx*s*.55,cy+dy*s-5*s],
            [cx+dx*s,cy+dy*s],[cx+dx*s*.5,cy+dy*s+2*s]],4,5);
        line(cx,cy,cx+dx*s,cy+dy*s,1);
    }
}
function skyline(y) {
    rect(0,y,256,160-y,2);
    for (let i=0;i<16;i++) {
        const x=i*18-8, h=12+(i*17%39);
        rect(x,y-h,15,h,1);
        line(x,y-h,x+15,y-h,12);
        for(let j=0;j<3;j++)
            for(let k=0;k<Math.floor(h/9);k++)
                if((i+j+k)%3) rect(x+3+j*4,y-h+5+k*8,2,3,(i+k)%4?10:11);
        line(x+6,y-h,x+6,y-h-6,1);
    }
}
function tower(x,y,s) {
    const p=(pts,c,d=c)=>poly(pts.map(([a,b])=>[x+a*s,y+b*s]),c,d);
    p([[-19,0],[19,0],[13,7],[-13,7]],14);
    p([[-19,-22],[19,-22],[19,0],[-19,0]],3,4);
    p([[-22,-25],[0,-32],[22,-25],[19,-21],[-19,-21]],7);
    p([[-14,7],[-10,7],[-15,52],[-20,52]],3);
    p([[10,7],[14,7],[20,52],[15,52]],3);
    for(let i=0;i<3;i++) {
        line(x-13*s,y+(10+i*13)*s,x+17*s,y+(24+i*13)*s,14);
        line(x+13*s,y+(10+i*13)*s,x-17*s,y+(24+i*13)*s,4);
    }
    line(x-14*s,y-19*s,x-14*s,y-1*s,7);
    line(x+7*s,y-20*s,x+7*s,y+43*s,1,2);
    for(let i=0;i<9;i++) line(x+5*s,y+(-17+i*6)*s,x+10*s,y+(-17+i*6)*s,14);
}
function plane(x,y,s) {
    poly([[x-37*s,y],[x+31*s,y-2*s],[x+40*s,y+2*s],
        [x+28*s,y+6*s],[x-34*s,y+5*s]],14);
    poly([[x-15*s,y+1*s],[x+9*s,y-17*s],[x+14*s,y-16*s],[x+4*s,y+3*s]],7);
    poly([[x-10*s,y+4*s],[x+9*s,y+19*s],[x+15*s,y+19*s],[x+3*s,y+4*s]],3);
    poly([[x-32*s,y+1*s],[x-39*s,y-13*s],[x-34*s,y-13*s],[x-20*s,y+2*s]],9);
    for(let i=-22;i<27;i+=5) rect(x+i*s,y+1*s,2*s,2*s,1);
}
function woman(x,y,s,old=false) {
    const p=(pts,c,d=c)=>poly(pts.map(([a,b])=>[x+a*s,y+b*s]),c,d);
    const e=(a,b,rx,ry,c,d=c)=>ellipse(x+a*s,y+b*s,rx*s,ry*s,c,d);
    p([[-26,105],[-22,66],[-12,55],[15,55],[31,72],[35,105]],old?12:1);
    p([[-23,73],[-13,60],[-6,65],[-11,101],[-27,104]],old?13:3);
    p([[14,59],[28,72],[33,100],[22,93],[11,70]],old?12:3);
    p([[-6,55],[-5,66],[4,74],[13,63],[12,49]],13);
    e(2,30,24,32,old?14:0);
    p([[-17,22],[-11,10],[10,7],[23,20],[22,32],[29,37],
        [21,41],[20,51],[10,60],[-3,54],[-13,42]],13);
    p([[-10,17],[-1,12],[17,15],[22,24],[14,22],[7,31],
        [-2,30],[-7,38],[-14,34]],old?7:8);
    p([[-20,17],[-10,3],[8,0],[23,13],[19,20],[5,14],[-5,21],[-11,42],[-18,55],[-26,65]],old?14:1);
    p([[-20,13],[-6,2],[7,2],[18,10],[1,7],[-13,23],[-19,43]],old?7:12);
    line(x+11*s,y+30*s,x+20*s,y+29*s,0);
    pixel(x+18*s,y+31*s,old?0:7);
    line(x+20*s,y+45*s,x+25*s,y+44*s,8);
    line(x-5*s,y+46*s,x+2*s,y+52*s,8);
    e(-9,35,3,6,10);
    if(old) {
        line(x+3*s,y+29*s,x+21*s,y+29*s,7);
        e(17,31,5,4,3);
        line(x-20*s,y+66*s,x+22*s,y+95*s,11,2*s);
    } else {
        p([[-12,60],[-4,71],[-14,82],[-7,86],[-20,102]],14);
        p([[13,60],[4,75],[16,85],[12,91],[25,102]],4);
        line(x-4*s,y+76*s,x+3*s,y+81*s,7);
        line(x+3*s,y+81*s,x+10*s,y+75*s,7);
        for(let i=0;i<4;i++) pixel(x+(-20+i*3)*s,y+(74+i*4)*s,15);
    }
}
function monkey(x,y,s) {
    const e=(a,b,rx,ry,c,d=c)=>ellipse(x+a*s,y+b*s,rx*s,ry*s,c,d);
    e(0,45,24,30,8,1);
    line(x-17*s,y+39*s,x-33*s,y+66*s,8,10*s);
    line(x+17*s,y+39*s,x+39*s,y+54*s,8,10*s);
    e(-23,12,9,12,8); e(23,12,9,12,8);
    e(-23,12,5,7,13); e(23,12,5,7,13);
    e(0,9,25,27,8,12);
    e(-9,10,11,14,13); e(9,10,11,14,13);
    e(0,25,17,12,13);
    line(x-17*s,y+4*s,x-3*s,y+7*s,0,3*s);
    line(x+3*s,y+7*s,x+17*s,y+4*s,0,3*s);
    e(-10,11,3,2,11); e(10,11,3,2,11);
    pixel(x-10*s,y+11*s,0); pixel(x+10*s,y+11*s,0);
    e(0,24,5,3,0); e(0,32,10,4,0);
    for(const a of [-6,4]) poly([[x+a*s,y+29*s],[x+(a+3)*s,y+29*s],
        [x+(a+1)*s,y+35*s]],7);
    line(x+20*s,y+58*s,x+42*s,y+73*s,8,4*s);
    line(x+42*s,y+73*s,x+51*s,y+59*s,8,4*s);
}
function foliage() {
    for(let i=0;i<18;i++) {
        const x=i*17-15, y=137+(i*13%22);
        poly([[x-14,y+18],[x-8,y-14],[x,y+2],[x+7,y-25],
            [x+14,y+8],[x+23,y-10],[x+22,y+25]],1,4);
        line(x,y+15,x+7,y-17,5);
    }
}
function tropical() {
    rect(0,0,256,80,4,5);
    rect(0,61,256,44,6,7);
    ellipse(186,39,24,24,11,7);
    poly([[0,87],[25,66],[51,75],[88,61],[114,81],[167,74],[210,92],[256,78],[256,114],[0,114]],3,4);
    rect(0,106,256,54,5,4);
    for(let i=0;i<27;i++) line((i*37)%256,92+i*2,(i*37)%256+20,92+i*2,6);
    poly([[78,160],[103,120],[125,103],[140,106],[123,123],[144,160]],11,13);
    palm(36,151,1.5); palm(227,128,.95); palm(7,125,.8);
    woman(161,52,.87,true);
    rect(173,136,29,24,8); rect(178,131,16,6,11);
    foliage();
    text("1982-1984",83,11,1);
}
function bite() {
    rect(0,0,256,160,1,4);
    for(let i=0;i<14;i++) {
        line(i*23-15,0,i*18+10,160,i%2?4:5,3);
        poly([[i*23,0],[i*23+20,19],[i*23+9,60],[i*23+3,23]],5,6);
    }
    line(0,145,251,44,8,12);
    line(0,141,251,40,11);
    monkey(80,42,1.15);
    poly([[256,86],[233,81],[164,111],[139,111],[124,122],
        [131,136],[153,139],[176,128],[245,116],[256,122]],13);
    poly([[256,86],[233,81],[222,86],[240,118],[256,122]],7,14);
    line(160,115,167,127,8,2);
    ellipse(162,122,2,3,9); ellipse(169,120,2,3,9);
    line(166,126,172,139,9,2);
    foliage();
}
function flight() {
    rect(0,0,256,160,3,14);
    poly([[0,0],[256,0],[213,44],[41,44]],7,14);
    line(0,25,256,25,3);
    rect(85,12,61,4,7);
    poly([[0,0],[31,42],[40,160],[0,160]],2,3);
    for(let i=0;i<3;i++) {
        const x=22+i*91;
        ellipse(x,61,24,34,1); ellipse(x,61,19,28,3);
        ellipse(x,60,16,25,1);
        line(x-12,71,x+13,71,12);
        for(let j=0;j<7;j++) pixel(x-11+(j*7%23),51+j*3,7);
    }
    rect(65,69,89,91,1); ellipse(109,69,44,17,1);
    rect(71,71,77,89,4,3);
    woman(111,48,.86,true);
    poly([[75,117],[146,117],[150,128],[73,129]],7,14);
    line(96,103,126,150,14,4);
    line(84,142,148,142,14,5);
    line(140,101,151,127,13,4);
    rect(139,112,14,9,7); rect(145,113,6,7,8,9);
    poly([[175,160],[174,113],[184,85],[198,80],[216,95],[224,160]],1);
    ellipse(192,72,13,17,13); poly([[178,69],[180,54],[199,54],[205,66]],1);
    line(180,116,150,125,13,6);
    text("CONGONHAS",8,145,7);
}
function hospital() {
    rect(0,0,256,160,4,3);
    poly([[0,0],[256,0],[186,43],[65,43]],14,7);
    poly([[0,160],[65,103],[186,103],[256,160]],3,4);
    rect(66,42,120,62,1);
    rect(78,51,89,47,4,5);
    rect(103,52,7,29,7); rect(93,62,27,7,7);
    rect(80,10,99,7,15); rect(93,17,73,3,5);
    for(let y=50;y<150;y+=17) line(0,y,64,43+(y-43)*.45,14);
    for(let y=55;y<150;y+=17) line(187,43+(y-43)*.45,256,y,14);
    poly([[24,106],[88,89],[164,116],[128,144],[32,125]],14);
    poly([[29,102],[72,89],[111,97],[151,119],[126,132],[39,115]],7,14);
    ellipse(44,100,11,7,13);
    poly([[32,100],[34,92],[46,91],[54,96]],14);
    line(36,127,36,147,1,3); line(129,140,129,155,1,3);
    ellipse(36,150,5,5,0); ellipse(129,156,5,5,0);
    rect(179,57,61,45,8,12);
    for(let y=60;y<100;y+=8) {
        line(179,y,240,y,13);
        for(let x=179+(y%16?0:9);x<240;x+=18) line(x,y,x,y+8,13);
    }
    line(218,70,218,125,3,6); line(218,123,246,123,3,6);
    line(218,70,218,125,14); line(219,124,246,124,14);
    rect(207,118,13,6,0); line(213,122,206,142,5,3);
    ellipse(208,145,18,4,5,6);
    line(166,23,164,153,10,3); line(236,14,248,154,10,3);
    for(let y=35;y<150;y+=21) line(165,y,242,y-5,10,3);
    text("OBRAS",186,32,0); text("OBRAS",185,31,11);
}
function water() {
    rect(0,0,256,160,2,12);
    rect(0,47,256,32,9,12);
    ellipse(45,53,22,22,10,11);
    skyline(108);
    tower(171,46,1.18);
    rect(130,107,79,21,4);
    poly([[126,107],[169,94],[211,107]],3,14);
    rect(143,112,9,16,1); rect(185,112,15,9,6);
    poly([[0,159],[83,120],[131,126],[96,144],[126,160]],3,14);
    for(let i=0;i<9;i++) {
        const x=i*31-9;
        line(x,139,x+4,91-(i%3)*13,1,4);
        for(let j=0;j<4;j++) ellipse(x-7+j*6,88-(i%3)*13+(j%2)*7,12,15,1,4);
    }
    poly([[190,160],[212,139],[256,144],[256,160]],8);
    for(let i=0;i<5;i++) {
        const x=21+i*41,y=130+i%2*9;
        ellipse(x,y-16,3,4,6);
        line(x,y-12,x-2,y+1,1,5);
        line(x-2,y,x-6,y+12,1,2); line(x-2,y,x+4,y+11,1,2);
        line(x,y-10,x+9,y-4,6);
    }
    line(0,153,256,153,0,6);
    line(0,151,256,151,5,2);
    for(let i=0;i<8;i++) rect(i*33,148,5,9,5);
}
function bedroom() {
    rect(0,0,256,160,2,12);
    rect(142,10,99,96,1); rect(146,14,91,87,9,10);
    ellipse(193,40,20,20,11);
    for(let i=0;i<6;i++) {
        rect(147+i*15,64-i%3*9,13,38+i%3*9,2);
        rect(151+i*15,72-i%3*9,3,5,11);
    }
    rect(188,12,4,91,1); rect(145,57,94,4,1);
    poly([[138,7],[151,10],[155,96],[137,114]],8,12);
    poly([[233,9],[247,5],[254,117],[229,105]],8,12);
    rect(11,12,66,58,0); rect(14,15,60,52,3);
    text("HEAVY",20,20,7); text("METAL",20,30,10);
    poly([[25,61],[39,40],[44,53],[56,38],[66,60]],1);
    line(20,63,64,63,9);
    rect(81,17,40,26,1); text("1984",87,22,7);
    for(let i=0;i<5;i++) rect(83+i*7,34,3,3,10);
    rect(0,124,256,36,8,12); line(0,124,256,124,13,2);
    rect(14,76,73,49,1); rect(18,80,65,37,14);
    rect(23,84,54,28,0); rect(26,86,48,24,4,1);
    text("MSX",31,91,6); text("READY",29,102,7);
    rect(44,122,16,7,3);
    poly([[18,130],[89,130],[100,145],[9,145]],14);
    for(let y=133;y<143;y+=4) for(let x=20;x<87;x+=6) rect(x,y,4,2,1);
    text("MSX1",36,119,7);
    poly([[102,130],[136,130],[145,143],[98,143]],1);
    for(let i=0;i<5;i++) line(105+i*4,133,111+i*4,139,13);
    rect(112,124,12,8,0); line(118,124,118,115,14,2);
    ellipse(118,114,4,3,9);
    rect(4,148,59,12,0); rect(9,151,48,7,14);
    ellipse(19,154,4,3,1); ellipse(44,154,4,3,1);
    rect(97,151,34,9,7); line(100,154,127,154,3);
    woman(182,61,.82);
    line(0,116,12,122,0,2); line(11,122,5,142,0);
    for(let i=0;i<3;i++) rect(218+i*9,130-i*3,7,30+i*3,i%2?1:3);
}
function title() {
    rect(0,0,256,160,1,2);
    for(let i=0;i<5;i++)
        poly([[0,90+i*12],[256,1+i*12],[256,8+i*12],[0,97+i*12]],
            [8,9,10,11,4][i],1);
    ellipse(52,92,32,31,10,9);
    skyline(137);
    tower(58,92,.76);
    plane(199,62,.63);
    monkey(219,110,.58);
    woman(147,49,1.03);
    for(let i=0;i<5;i++) {
        const x=9+i*15;
        ellipse(x,147-i%2*5,3,4,6);
        line(x,151-i%2*5,x-2,160,0,5);
    }
    // Lettering is drawn last, like a painted cassette-cover masthead.
    text("BLOODSTRAIN",18,12,0,3);
    text("BLOODSTRAIN",16,10,9,3);
    text("BLOODSTRAIN",16,9,10,3);
    for(let i=0;i<10;i++) line(18+i*21,30,18+i*21,34+i*7%12,9);
    line(11,47,244,47,8);
    text("SAO PAULO - 1982/1984",11,149,7);
}
function write(file,bytes) {
    if(check) assert(fs.existsSync(file) && fs.readFileSync(file).equals(bytes),
        `Stale or missing generated file: ${file}`);
    else { fs.mkdirSync(path.dirname(file),{recursive:true}); fs.writeFileSync(file,bytes); }
}
function crc32(buf) {
    let crc=0xffffffff;
    for(const byte of buf) {
        crc^=byte;
        for(let i=0;i<8;i++) crc=(crc>>>1)^((crc&1)?0xedb88320:0);
    }
    return (crc^0xffffffff)>>>0;
}
function png(pixels,width,height) {
    function chunk(type,data) {
        const name=Buffer.from(type), len=Buffer.alloc(4), sum=Buffer.alloc(4);
        len.writeUInt32BE(data.length); sum.writeUInt32BE(crc32(Buffer.concat([name,data])));
        return Buffer.concat([len,name,data,sum]);
    }
    const header=Buffer.alloc(13); header.writeUInt32BE(width); header.writeUInt32BE(height,4);
    header[8]=8; header[9]=2;
    const raw=Buffer.alloc((width*3+1)*height);
    for(let y=0;y<height;y++) for(let x=0;x<width;x++)
        palette[pixels[y*width+x]].forEach((v,c)=>{
            raw[y*(width*3+1)+1+x*3+c]=Math.round(v*255/7);
        });
    return Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),
        chunk("IHDR",header),chunk("IDAT",zlib.deflateSync(raw)),chunk("IEND",Buffer.alloc(0))]);
}
const previews=[];
const compressed=[];
const scratch=path.join(root,"build","generated","intro-compress");
fs.mkdirSync(scratch,{recursive:true});
function crc16(bytes) {
    let crc=0xffff;
    for(const value of bytes) {
        crc^=value;
        for(let bit=0;bit<8;bit++) crc=(crc>>>1)^((crc&1)?0xa001:0);
    }
    return crc;
}
const painters=[tropical,bite,flight,hospital,water,bedroom,title];
painters.forEach((paint,index)=>{
    image=new Uint8Array(W*H);
    paint();
    rect(0,160,W,52,0); rect(0,160,W,1,8);
    // A small numbered film-frame corner also makes runtime verification unambiguous.
    rect(0,0,2,1,index+1);
    const packed=Buffer.alloc(W*H/2);
    for(let i=0;i<packed.length;i++) packed[i]=(image[i*2]<<4)|image[i*2+1];
    assert.strictEqual(packed.length,27136);
    const filename=index<6?scenes[index][0]:"TITLE.SC5";
    write(path.join(out,filename),packed);
    const raw=path.join(scratch,"image.raw"), zip=path.join(scratch,"image.zx0");
    const decoded=path.join(scratch,"decoded.raw");
    for(const [start,end] of [[0,16384],[16384,20480]]) {
        fs.writeFileSync(raw,packed.subarray(start,end));
        execFileSync(path.join(root,"MSXgl","tools","compress","ZX0","zx0.exe"),
            ["-f",raw,zip],{stdio:"pipe"});
        execFileSync(path.join(root,"MSXgl","tools","compress","ZX0","dzx0.exe"),
            ["-f",zip,decoded],{stdio:"pipe"});
        assert(fs.readFileSync(decoded).equals(packed.subarray(start,end)),
            `ZX0 round trip failed: ${filename}/${start}`);
        compressed.push(fs.readFileSync(zip));
    }
    if(index<6) {
        const [,heading,a,b]=scenes[index];
        for(const caption of [heading,a,b]) assert(caption.length<=40);
        text(heading,6,165,10,1,true); text(a,6,177,7,1,true); text(b,6,187,7,1,true);
        text("SPACE/ENTER: SEGUE  S: PULA  ESC: DOS",6,202,14,1,true);
    } else {
        text("UM BAIRRO. MUITOS CAMINHOS.",35,166,7);
        text("SPACE/ENTER: INTRO  ESC: DOS",28,188,14);
        text("BLOODSTRAIN - MSX2",77,201,10);
    }
    previews.push(image.slice());
    write(path.join(out,filename.replace(".SC5",".png")),png(image,W,H));
});
const sheet=new Uint8Array(512*848);
previews.forEach((preview,index)=>{
    const ox=index%2*256,oy=Math.floor(index/2)*212;
    for(let y=0;y<H;y++) for(let x=0;x<W;x++) sheet[(y+oy)*512+x+ox]=preview[y*W+x];
});
write(path.join(out,"storyboard.png"),png(sheet,512,848));
const pal=palette.flatMap(([r,g,b])=>[(r<<4)|b,g]);
write(path.join(out,"INTRO.PAL"),Buffer.from(pal));
let total=0;
for(const bytes of compressed) total+=bytes.length;
const maxChunk=Math.max(...compressed.map(bytes=>bytes.length));
assert(maxChunk<=6144,`Compressed read buffer exceeds RAM budget: ${maxChunk}`);
const archive=Buffer.concat(compressed);
write(path.join(out,"INTRO.PAK"),archive);
const cards=[
    ["Sudeste Asiatico. 1982-1984.",
     "Uma brasileira percorre trilhas",
     "tropicais, longe de Sao Paulo.",
     "Entre as folhas, algo a observa."],
    ["Um grito. Dentes no braco.",
     "O macaco desaparece na mata.",
     "Um curativo parece suficiente.",
     "Ninguem imagina o que ela leva."],
    ["No voo, a ferida piora.",
     "Febre e violencia: e preciso",
     "conter a passageira. De Congonhas,",
     "uma ambulancia segue para a Mooca."],
    ["O hospital esta em obras.",
     "A equipe tenta salva-la. Ela morre.",
     "A limpeza comeca. Na lavanderia,",
     "um cano leva residuos para a agua."],
    ["Torres, parque, casas e torneiras.",
     "A contaminacao atravessa o bairro.",
     "Uns se arrastam. Outros atacam.",
     "A noite cai. Os passos continuam."],
    ["Voce tem 25 anos: metal, Atari",
     "e um MSX1 recem-adquirido.",
     "So falta comida para a madrugada.",
     "Era para ser so uma ida ao mercado."]
];
for(const lines of cards) for(const line of lines)
    assert(line.length<=40 && /^[\x20-\x7e]+$/.test(line));
const header=`// Generated by assets/art/source/intro.js. Do not edit.
// SPDX-License-Identifier: GPL-3.0-only
static const u8 g_IntroPalette[] = { ${pal.join(", ")} };
static const u16 g_IntroSizes[] = { ${compressed.map(bytes=>bytes.length).join(", ")} };
static const u16 g_IntroChecksums[] = { ${compressed.map(crc16).join(", ")} };
static const c8* const g_IntroCards[6][4] = {
${cards.map(lines=>"    { "+lines.map(s=>JSON.stringify(s)).join(", ")+" }").join(",\n")}
};
static const IntroScene g_IntroScenes[] = {
${scenes.map(s=>"    { "+s.map(v=>JSON.stringify(v)).join(", ")+" }").join(",\n")}
};
#define INTRO_SCENE_COUNT 6
#define INTRO_PACK_BYTES ${total}
#define INTRO_BUFFER_BYTES ${maxChunk}
`;
write(path.join(root,"build","generated","intro_data.h"),Buffer.from(header));
for(const file of ["image.raw","image.zx0","decoded.raw"]) fs.unlinkSync(path.join(scratch,file));
fs.rmdirSync(scratch);
console.log(`${check?"Verified":"Generated"} six scenes and title: ${7*27136} -> ${total} bytes (${(100-total*100/(7*27136)).toFixed(1)}% smaller).`);
