// SPDX-License-Identifier: GPL-3.0-only
// Original, fictional 1980s Mooca block. Coordinates also define collision data.
"use strict";
const fs = require("fs"), path = require("path"), zlib = require("zlib");
const {execFileSync} = require("child_process");
const assert = require("assert");
const root = path.resolve(__dirname, "..", "..", "..");
const out = path.join(root, "assets", "art", "export");
const scratch = path.join(root, "build", "generated", "block");
const check = process.argv.includes("--check");
fs.mkdirSync(scratch, {recursive:true});
const palette = [[0,0,0],[1,1,2],[1,2,2],[2,2,3],[1,2,1],[2,3,1],
    [3,2,1],[4,4,2],[3,0,1],[3,1,1],[6,4,2],[7,6,3],[2,3,3],[3,4,3],[3,3,3],[6,6,5]];
let pixels, walk;
function rect(x,y,w,h,c) {
    for(let j=Math.max(0,y);j<Math.min(192,y+h);j++)
        for(let i=Math.max(0,x);i<Math.min(256,x+w);i++) pixels[j*256+i]=c;
}
function shadow(x,y,w,h) {
    const shade=[0,0,1,2,1,4,1,6,1,8,6,7,2,12,3,13];
    for(let j=Math.max(0,y);j<Math.min(192,y+h);j++)
        for(let i=Math.max(0,x);i<Math.min(256,x+w);i++)
            pixels[j*256+i]=shade[pixels[j*256+i]];
}
function solid(x,y,w,h) {
    assert(x%8===0 && y%8===0 && w%8===0 && h%8===0);
    for(let j=y/8;j<(y+h)/8;j++) for(let i=x/8;i<(x+w)/8;i++) walk[j*32+i]=0;
}
function tree(x,y) {
    rect(x+9,y+17,6,15,6); rect(x+3,y+8,24,17,4);
    rect(x,y+5,24,15,5);rect(x+6,y,16,24,5);
    rect(x+6,y+4,5,5,4);solid(x+8,y+16,8,16);
}
function window(x,y,w=24) {
    rect(x,y,w,16,1);rect(x+2,y+2,w-4,12,12);rect(x+4,y+3,3,9,7);
    rect(x+w/2,y,2,16,6);rect(x,y+14,w,2,6);
}
function building(x,y,w,h,color,roof=9) {
    shadow(x+4,y+4,w,h+4);
    rect(x,y,w,h,color);rect(x,y,w,24,roof);
    for(let j=y+2;j<y+24;j+=4) rect(x,j,w,1,6);
    for(let i=x+8;i<x+w;i+=12) rect(i,y,1,24,6);
    rect(x,y+24,w,3,1);rect(x,y+h-3,w,3,6);
    shadow(x,y+27,5,h-30);
}
function street() {
    rect(0,0,256,192,14);rect(0,104,256,32,3);
    rect(0,100,256,4,12);rect(0,136,256,4,12);
    for(let x=0;x<256;x+=16) {rect(x,72,1,28,2);rect(x,140,1,12,2);}
    for(let x=4;x<256;x+=40) rect(x,119,20,2,7);
    rect(0,152,256,40,6);solid(0,152,256,40);
    for(let x=0;x<256;x+=16) rect(x,154,1,38,1);
    for(let x=12;x<256;x+=64) {rect(x,97,12,1,3);rect(x+2,98,1,2,3);}
    rect(64,102,12,2,1);rect(208,136,12,2,1);
}
function shelves(x,y,w,h) {
    shadow(x+4,y+4,w,h);
    rect(x,y,w,h,6);rect(x+2,y+2,w-4,h-4,7);
    for(let j=y+3;j<y+h-2;j+=8) for(let i=x+3;i<x+w-2;i+=6) {
        rect(i,j,4,5,(i+j)%3===0?8:5);rect(i,j+2,4,1,13);
    }
    solid(x,y,w,h);
}
function indoor() {
    rect(0,0,256,192,14);
    for(let y=32;y<176;y+=8) for(let x=16;x<240;x+=8)
        rect(x,y,8,8,((x+y)/8)%2 ? 14:12);
    shadow(16,32,224,8);shadow(16,32,8,144);shadow(232,32,8,144);
    rect(0,0,256,32,12);rect(0,0,256,8,1);
    rect(0,32,16,160,6);rect(240,32,16,160,6);
    rect(0,176,256,16,6);
    solid(0,0,256,32);solid(0,32,16,160);solid(240,32,16,160);solid(0,176,256,16);
}
// Portal target 255 is a visible, unfinished continuation, never an invisible wall.
const rooms = [
    {name:"ORATORIO - CAMINHO DE CASA",spawn:[224,88],labels:[
        [5,4,"R. CRICIUMAL",11],[91,48,"CASAS",15],[100,181,"FUNDOS - SEM PASSAGEM",7]],
    portals:[[0,104,8,32,255,0,0],[248,72,8,80,1,12,88]],
    paint() {
        street();
        for(let x=72;x<256;x+=64) {
            building(x,0,56,72,13);window(x+6,36,24);rect(x+36,34,14,35,6);solid(x,0,56,72);
        }
        rect(8,16,48,88,3);rect(8,64,64,32,3);
        for(let x=16;x<64;x+=16) rect(x,78,8,2,11);
        rect(8,16,48,4,10);solid(8,16,48,8);
        tree(184,144);
        rect(88,148,32,4,1);rect(88,145,32,2,6);
        rect(128,78,3,20,6);rect(125,76,9,3,11);solid(128,88,8,8);
        for(let x=20;x<50;x+=8) rect(x,106,4,28,14);
    }},
    {name:"ORATORIO - MERCADO E FARMACIA",spawn:[128,88],labels:[
        [16,30,"MERCADINHO",11],[124,173,"FARMACIA",15],[10,183,"BAIRRO DA MOOCA - 1983",7]],
    portals:[[0,72,8,80,0,244,88],[248,72,8,80,2,12,88],
        [64,64,16,16,3,72,164],[160,152,16,16,4,168,48]],
    paint() {
        street();building(8,0,136,72,7);solid(8,0,136,64);
        solid(8,64,56,8);solid(80,64,64,8);
        rect(8,27,136,15,8);
        for(let x=10;x<144;x+=12) rect(x,43,6,7,5);
        window(16,51,40);window(88,51,40);rect(64,50,16,30,1);rect(66,51,12,25,6);
        building(168,0,88,72,13);solid(168,0,88,72);window(180,38,48);
        building(112,152,128,40,13,12);
        for(let y=152;y<168;y++) walk[Math.floor(y/8)*32+20]=walk[Math.floor(y/8)*32+21]=1;
        rect(160,148,16,23,1);window(184,153,40);
        rect(128,154,4,12,15);rect(124,158,12,4,15);
        tree(16,144);
        rect(192,83,6,14,1);rect(189,81,12,5,12);solid(192,88,8,8);
        rect(86,76,8,6,6);rect(88,73,4,5,5);
        rect(140,78,8,6,6);rect(142,75,4,5,5);
    }},
    {name:"ORATORIO - VIELA E TEATRO",spawn:[128,88],labels:[
        [65,30,"OFICINA",11],[179,41,"DEPOSITO",15],[130,5,"TEATRO",11],
        [7,75,"VIELA",15],[180,113,"DELEGACIA >",11]],
    portals:[[0,72,8,80,1,244,88],[248,104,8,32,255,0,0],
        [144,0,32,8,255,0,0],[24,48,8,16,3,228,80]],
    paint() {
        street();
        rect(24,0,32,76,13);rect(24,0,4,72,6);rect(52,0,4,72,6);
        rect(0,0,24,72,7);solid(0,0,24,72);rect(20,48,8,16,1);
        building(56,0,88,72,7);solid(56,0,88,72);rect(64,45,64,24,3);
        for(let y=48;y<68;y+=4) rect(64,y,64,1,13);
        building(176,0,80,72,13);solid(176,0,80,72);window(190,48,40);
        rect(144,0,32,104,3);rect(144,24,32,3,11);
        rect(56,144,72,8,12);solid(56,144,72,8);
        rect(64,142,56,6,13);rect(72,142,16,6,1);rect(96,142,16,6,1);
        tree(208,144);
        rect(160,56,8,16,10);rect(158,53,12,6,8);
        solid(160,56,8,16);
        for(let y=8;y<40;y+=8) rect(29,y,2,3,14);
    }},
    {name:"MERCADO - ENTRADA E ESTOQUE",spawn:[72,164],labels:[
        [18,13,"MERCADINHO - SECOS E MOLHADOS",15],[24,43,"CAIXA",15],
        [165,37,"ESTOQUE",15],[151,164,"SAIDA PELA VIELA >",15]],
    portals:[[64,176,16,16,1,72,88],[232,72,8,16,2,40,56]],
    paint() {
        indoor();
        for(let j=22;j<=23;j++) {walk[j*32+8]=1;walk[j*32+9]=1;}
        rect(64,176,16,16,1);
        rect(232,72,24,16,1);walk[9*32+30]=walk[10*32+30]=1;
        shelves(24,56,32,32);rect(32,55,12,8,1);
        shelves(88,56,32,64);shelves(144,56,32,64);
        shelves(192,112,32,32);shelves(192,40,32,24);
        rect(32,112,24,24,9);solid(32,112,24,24);
        for(let y=116;y<136;y+=8) rect(33,y,22,1,6);
        rect(18,152,30,4,6);rect(24,150,18,2,5);
    }},
    {name:"FARMACIA - BALCAO E VITRINES",spawn:[168,48],labels:[
        [28,12,"FARMACIA - MANIPULACAO",15],[35,80,"BALCAO",15],
        [148,152,"VITRINE",15],[145,34,"RUA",15]],
    portals:[[160,24,16,8,1,168,144]],
    paint() {
        indoor();rect(160,24,16,8,1);walk[3*32+20]=walk[3*32+21]=1;
        shelves(24,40,80,24);shelves(24,88,104,24);
        shelves(24,128,32,32);shelves(200,64,24,64);
        rect(144,160,72,8,12);solid(144,160,72,8);
        for(let x=148;x<212;x+=8) rect(x,157,4,7,15);
        rect(144,72,16,16,6);solid(144,72,16,16);
        rect(147,75,10,10,7);rect(150,73,4,14,15);
    }}
];
function crc16(data) {
    let crc=65535;
    for(const n of data) {crc^=n;for(let i=0;i<8;i++) crc=(crc>>>1)^((crc&1)?0xA001:0);}
    return crc;
}
function crc32(data) {
    let c=0xFFFFFFFF;
    for(const n of data) {c^=n;for(let i=0;i<8;i++) c=(c>>>1)^((c&1)?0xEDB88320:0);}
    return (c^0xFFFFFFFF)>>>0;
}
function png(data,w,h) {
    function chunk(name,b) {const t=Buffer.from(name),n=Buffer.alloc(4),c=Buffer.alloc(4);n.writeUInt32BE(b.length);c.writeUInt32BE(crc32(Buffer.concat([t,b])));return Buffer.concat([n,t,b,c]);}
    const ih=Buffer.alloc(13);ih.writeUInt32BE(w);ih.writeUInt32BE(h,4);ih[8]=8;ih[9]=2;
    const rows=Buffer.alloc(h*(w*3+1));
    for(let y=0;y<h;y++) for(let x=0;x<w;x++) palette[data[y*w+x]].forEach((v,i)=>rows[y*(w*3+1)+1+x*3+i]=Math.round(v*255/7));
    return Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk("IHDR",ih),chunk("IDAT",zlib.deflateSync(rows)),chunk("IEND",Buffer.alloc(0))]);
}
function persist(file,data) {
    if(check) assert(fs.readFileSync(file).equals(Buffer.from(data)),`Stale: ${file}`);
    else {fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,data);}
}
const blocks=[],meta=[],maps=[];
let offset=0;
for(const [id,room] of rooms.entries()) {
    pixels=Buffer.alloc(256*192);walk=new Uint8Array(32*24).fill(1);
    room.paint();maps.push(pixels);
    const mask=Buffer.alloc(96);
    walk.forEach((v,i)=>{if(v) mask[i>>>3]|=1<<(i&7);});
    room.mask=mask;
    persist(path.join(out,`BLOCK${id}.SC5`),Buffer.from(Array.from({length:24576},(_,i)=>(pixels[i*2]<<4)|pixels[i*2+1])));
    persist(path.join(out,`BLOCK${id}.png`),png(pixels,256,192));
    const raw=fs.existsSync(path.join(out,`BLOCK${id}.SC5`)) ? fs.readFileSync(path.join(out,`BLOCK${id}.SC5`)) : null;
    const sizes=[],crcs=[];
    for(let part=0;part<2;part++) {
        const src=path.join(scratch,"raw.bin"),zip=path.join(scratch,"block.zx0"),decoded=path.join(scratch,"decoded.bin");
        fs.writeFileSync(src,raw.subarray(part*12288,(part+1)*12288));
        execFileSync(path.join(root,"MSXgl","tools","compress","ZX0","zx0.exe"),["-f",src,zip]);
        execFileSync(path.join(root,"MSXgl","tools","compress","ZX0","dzx0.exe"),["-f",zip,decoded]);
        assert(fs.readFileSync(src).equals(fs.readFileSync(decoded)));
        const b=fs.readFileSync(zip);assert(b.length<=4096);
        blocks.push(b);sizes.push(b.length);crcs.push(crc16(b));
        for(const f of [src,zip,decoded]) fs.unlinkSync(f);
    }
    meta.push({offset,sizes,crcs});offset+=sizes[0]+sizes[1];
}
// Check walkable spawns and every doorway, and connectivity within each room.
for(const [id,r] of rooms.entries()) {
    const isWalk=(x,y)=>x>=0&&x<256&&y>=0&&y<192&&!!(r.mask[(Math.floor(y/8)*32+Math.floor(x/8))>>>3]&(1<<(Math.floor(x/8)&7)));
    const fits=(x,y)=>x>=4&&x<=251&&y>=4&&y<=191&&
        isWalk(x-3,y)&&isWalk(x+3,y)&&isWalk(x-3,y-3)&&isWalk(x+3,y-3);
    r.fits=fits;
    assert(fits(...r.spawn),`Spawn ${id}`);
    const start=r.spawn[1]*256+r.spawn[0],seen=new Set([start]),queue=[start];
    for(let at=0;at<queue.length;at++) for(const d of [-256,256,-1,1]) {
        const n=queue[at]+d,x=n%256,y=Math.floor(n/256);
        if(!fits(x,y)||seen.has(n)) continue;
        seen.add(n);queue.push(n);
    }
    for(const p of r.portals) {
        assert(queue.some(n=>n%256>=p[0]&&n%256<p[0]+p[2]&&
            Math.floor(n/256)>=p[1]&&Math.floor(n/256)<p[1]+p[3]),`Unreachable portal ${id}: ${p}`);
    }
}
for(const [id,r] of rooms.entries()) for(const p of r.portals) if(p[4]!==255) {
    const target=rooms[p[4]];
    assert(target.fits(p[5],p[6]),`Arrival blocked ${id}`);
    assert(!target.portals.some(q=>p[5]>=q[0]&&p[5]<q[0]+q[2]&&
        p[6]>=q[1]&&p[6]<q[1]+q[3]),`Arrival retriggers portal ${id}`);
}
const sheet=Buffer.alloc(256*3*192*2);
maps.forEach((m,i)=>{for(let y=0;y<192;y++) m.copy(sheet,(Math.floor(i/3)*192+y)*768+(i%3)*256,y*256,(y+1)*256);});
persist(path.join(out,"block-storyboard.png"),png(sheet,768,384));
persist(path.join(out,"WORLD.PAK"),Buffer.concat(blocks));
let header="// Generated by block.js. SPDX-License-Identifier: GPL-3.0-only\n";
header+=`static const u16 g_WorldPalette[16] = {${palette.map(([r,g,b])=>`0x${((g<<8)|(r<<4)|b).toString(16)}`).join(",")}};\n`;
rooms.forEach((r,i)=>{
    header+=`static const u8 g_Walk${i}[96] = {${[...r.mask]}};\n`;
    header+=`static const Portal g_Portals${i}[] = {${r.portals.map(p=>`{${p}}`).join(",")}};\n`;
    header+=`static const Label g_Labels${i}[] = {${r.labels.map(([x,y,t,c])=>`{${x},${y},${c},"${t}"}`).join(",")}};\n`;
});
header+=`static const Room g_Rooms[5] = {\n${rooms.map((r,i)=>`{ "${r.name}", ${meta[i].offset}, {${meta[i].sizes}}, {${meta[i].crcs}}, g_Walk${i}, g_Portals${i}, ${r.portals.length}, g_Labels${i}, ${r.labels.length} }`).join(",\n")}\n};\n`;
// Four disjoint color layers in two vertical tiles: four sprites per scanline.
const front=[
    "......OOOO......",".....OHHHHO.....","....OHhHHHHO....","....OHHSSSHO....",
    "....OHSOOSHO....","....OHSSSSHO....","....OHSSSSHO....","....OHHSSHHHO...",
    "....OHHSSHHHO...","...OHHOSSOHHHO..","...OHSOOOOSHHO..","...OHSOOOOSHHO..",
    "....OSORROSO....","....OSRWWRSO....","....OSRRWRSO....","....OSORROSO....",
    "....OSOOOOSO....","....OSOOOOSO....","....OSOOOOSO....","....OMOMMOMO....",
    ".....ODDDDO.....",".....ODDLDO.....",".....ODOLDO.....",".....ODOLDO.....",
    ".....ODOLDO.....",".....ODOLDO.....",".....ODOLDO.....",".....ODOLDO.....",
    ".....ODOODO.....",".....OOOOOO.....",".....OOOOOO.....","....OMOOOOMO...."
];
const back=[
    "......OOOO......",".....OHHHHO.....","....OHhHHHHO....","....OHhHHHHO....",
    "....OHHHHHHO....","....OHHHHHHO....","....OHHHHHHO....","....OHHHHHHHO...",
    "....OHHHHHHHO...","...OHHHHHHHHHO..","...OHSHHHHSHHO..","...OHSHHHHSHHO..",
    "....OSOOOOSO....","....OSOOOOSO....","....OSOOOOSO....","....OSOOOOSO....",
    "....OSOOOOSO....","....OSOOOOSO....","....OSOOOOSO....","....OMOMMOMO....",
    ".....ODDDDO.....",".....ODDLDO.....",".....ODOLDO.....",".....ODOLDO.....",
    ".....ODOLDO.....",".....ODOLDO.....",".....ODOLDO.....",".....ODOLDO.....",
    ".....ODOODO.....",".....OOOOOO.....",".....OOOOOO.....","....OMOOOOMO...."
];
const left=[
    "......OOOO......",".....OHHHHO.....",".....HhHHHHO....",".....HSSHHHO....",
    "....OSOSHHHO....","....OSSSHHHO....",".....OSSHHHO....",".....OHHHHHO....",
    ".....OSHHHHO....",".....OSHHHHHO...",".....OOHHHHHO...",".....OSOHHHO....",
    ".....OSOROO.....",".....OSRWRO.....",".....OSORRO.....",".....OSOOO......",
    ".....OSOOO......",".....OSOOO......",".....OSOOO......",".....OMMMO......",
    ".....ODDDDO.....",".....ODDLDO.....",".....ODOLDO.....",".....ODOLDO.....",
    ".....ODOLDO.....",".....ODOLDO.....",".....ODOLDO.....",".....ODOLDO.....",
    ".....ODOODO.....",".....OOOOOO.....",".....OOOOOO.....","....OMOOOOMO...."
];
const spriteInk={".":0,O:1,H:6,h:7,S:10,R:9,W:15,M:13,D:14,L:12};
const templates=[front,back,left,left.map(row=>[...row].reverse().join(""))];
const frames=[],colors=[],portraits=[],patterns=[],tiles=new Map();
function layerColor(layer,y) {
    if(layer===0) return 1;
    if(layer===1) return y<12?6:y<19?9:y===19?13:14;
    if(layer===2) return y<20?10:12;
    return y<12?7:y<19?15:13;
}
for(let dir=0;dir<4;dir++) for(let step=0;step<3;step++) {
    const rows=templates[dir].map(row=>{
        assert(row.length===16);
        return [...row].map(c=>spriteInk[c]);
    });
    if(step) {
        const legs=[".....ODDLDO.....","....ODDOOLDO....","....ODD.OLDO....",
            "....ODD..OLDO...","...ODDO..OLDO...","...ODDO...OLDO..",
            "...ODDO...OLDO..","...ODDO....ODO..","...OOOO....OOO..",
            "..OMOOO....OOO..","...........OOO..","..........OMOOO."];
        for(let y=20;y<32;y++)
            rows[y]=[...(step===2?legs[y-20].split("").reverse().join(""):legs[y-20])].map(c=>spriteInk[c]);
        const forward=step===1?3:11, trailing=step===1?11:3;
        for(let y=12;y<19;y++) for(const x of [3,4,5,10,11,12])
            if(rows[y][x]===10) rows[y][x]=0;
        for(let y=12;y<15;y++) {
            rows[y][forward+(forward<8?1:0)]=10;
            rows[y][trailing+(trailing<8?1:0)]=10;
        }
        for(let y=14;y<17;y++) {
            rows[y][forward]=10;
            rows[y][forward+1]=10;
        }
        for(let y=15;y<19;y++) {
            rows[y][trailing+(trailing<8?1:0)]=y===17?1:10;
        }
    }
    portraits.push(rows);
    for(let tile=0;tile<2;tile++) for(let layer=0;layer<4;layer++) {
        const bytes=[];
        for(let half=0;half<2;half++) for(let y=0;y<16;y++) {
            const sy=tile*16+y,c=layerColor(layer,sy);
            let b=0;
            for(let x=0;x<8;x++) if(rows[sy][half*8+x]===c) b|=1<<(7-x);
            bytes.push(b);
        }
        const key=bytes.join(",");
        if(!tiles.has(key)) {tiles.set(key,frames.length/8);frames.push(...bytes);}
        patterns.push(tiles.get(key));
    }
    for(let y=0;y<32;y++) for(const c of rows[y])
        assert(c===0||[0,1,2,3].some(layer=>layerColor(layer,y)===c),`Unrenderable sprite color ${dir}/${step}/${y}`);
}
for(let dir=0;dir<4;dir++) {
    const arms=portraits.slice(dir*3,dir*3+3).map(rows=>
        rows.slice(12,19).map(row=>row.map(c=>c===10?1:0).join("")).join(""));
    assert(new Set(arms).size===3,`Arms must move in every direction: ${dir}`);
}
for(let tile=0;tile<2;tile++) for(let layer=0;layer<4;layer++)
    for(let y=0;y<16;y++) colors.push(layerColor(layer,tile*16+y));
const preview=Buffer.alloc(128*120,2);
portraits.forEach((rows,i)=>rows.forEach((row,y)=>row.forEach((c,x)=>{
    if(c) preview[((i%3)*40+y+4)*128+Math.floor(i/3)*32+x+8]=c;
})));
persist(path.join(out,"protagonist.png"),png(preview,128,120));
const enlarged=Buffer.alloc(512*480);
for(let y=0;y<480;y++) for(let x=0;x<512;x++)
    enlarged[y*512+x]=preview[Math.floor(y/4)*128+Math.floor(x/4)];
persist(path.join(out,"protagonist-detail.png"),png(enlarged,512,480));
persist(path.join(out,"protagonist.spr"),Buffer.from([...frames,...colors]));
assert(frames.length<=2048 && colors.length===128,`Sprite patterns: ${frames.length}/2048 bytes, colors: ${colors.length}`);
const spriteRaw=path.join(scratch,"sprite.bin"),spriteZip=path.join(scratch,"sprite.zx0"),spriteDecoded=path.join(scratch,"sprite-decoded.bin");
fs.writeFileSync(spriteRaw,Buffer.from(frames));
execFileSync(path.join(root,"MSXgl","tools","compress","ZX0","zx0.exe"),["-f",spriteRaw,spriteZip]);
execFileSync(path.join(root,"MSXgl","tools","compress","ZX0","dzx0.exe"),["-f",spriteZip,spriteDecoded]);
assert(fs.readFileSync(spriteRaw).equals(fs.readFileSync(spriteDecoded)));
const packed=fs.readFileSync(spriteZip);
for(const file of [spriteRaw,spriteZip,spriteDecoded]) fs.unlinkSync(file);
header+=`#define PLAYER_PATTERN_BYTES ${frames.length}\n`;
header+=`static const u8 g_PlayerPatterns[${packed.length}] = {${[...packed]}};\n`;
header+=`static const u8 g_PlayerFrames[96] = {${patterns}};\n`;
header+=`static const u8 g_PlayerColors[128] = {${colors}};\n`;
persist(path.join(root,"build","generated","block_data.h"),header);
console.log(`${check?"Verified":"Generated"} five block rooms, connected portals, sprite frames; WORLD.PAK ${offset} bytes.`);
