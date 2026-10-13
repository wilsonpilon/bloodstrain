# Validação

O pipeline executa `scripts/verify.ps1` antes de concluir um release:

- verifica arquivos obrigatórios;
- exige DSK de 737280 bytes;
- extrai o COM do DSK e compara SHA-256;
- verifica o manifesto de checksums;
- confere fontes essenciais no SOURCE.zip.

Para repetir sem compilar e sem aumentar Z:

```powershell
.\scripts\verify.ps1 -PackagePath .\dist\Bloodstrain-1.1.4 -ArchivePath .\dist\Bloodstrain-1.1.4.zip
```

Para testar runtime sem compilar:

```powershell
.\scripts\smoke.ps1 -PackagePath .\dist\Bloodstrain-1.1.4 -DosFilesPath .\MSXgl\tools\build\DOS -BootTemplatePath .\msxDiskUtil\msxdos.dsk
```

O smoke test exige openMSX e suas ROMs legítimas, usa MSX2 com duas unidades e DOS2, verifica modo de abertura, display ligado e faixas na VRAM, injeta ESC e exige que o DOS execute `ECHO RETURN_OK`. Captura as duas telas em `build/smoke` e mede dimensões e cores no PNG da abertura. A mídia privada de sistema é removida ao terminar e nunca incluída no pacote. Preferências pessoais do emulador não são gravadas.

Testes de gameplay ainda não existem. Hardware físico, 50/60 Hz e configurações alternativas devem ser registrados separadamente em OUTLINE.
