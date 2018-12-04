﻿return function(sTool, sLimit) local tPool = {} -- Bulgarian
  tPool["tool."..sTool..".name"       ] = "Спинер"
  tPool["tool."..sTool..".desc"       ] = "Създава/Актуализира спинер обект"
  tPool["tool."..sTool..".left"       ] = "Създава/Актуализира спинер"
  tPool["tool."..sTool..".left_use"   ] = "Създава/Актуализира спинер"
  tPool["tool."..sTool..".right"      ] = "Копирай настройки"
  tPool["tool."..sTool..".right_use"  ] = "Копирай настройки"
  tPool["tool."..sTool..".reload"     ] = "Премахни спинера"
  tPool["tool."..sTool..".constraint" ] = "Тип ограничение"
  tPool["tool."..sTool..".constraint0"] = "Пропусни връзка"
  tPool["tool."..sTool..".constraint1"] = "Завари спинера"
  tPool["tool."..sTool..".constraint2"] = "Ос по нормалата"
  tPool["tool."..sTool..".constraint3"] = "Става при спинера"
  tPool["tool."..sTool..".constraint4"] = "Става при трейса"
  tPool["tool."..sTool..".diraxis"    ] = "Направление на оста"
  tPool["tool."..sTool..".diraxis0"   ] = "<Персонално>"
  tPool["tool."..sTool..".diraxis1"   ] = "+X Червена"
  tPool["tool."..sTool..".diraxis2"   ] = "+Y Зелена"
  tPool["tool."..sTool..".diraxis3"   ] = "+Z Синя"
  tPool["tool."..sTool..".diraxis4"   ] = "-X Червена"
  tPool["tool."..sTool..".diraxis5"   ] = "-Y Зелена"
  tPool["tool."..sTool..".diraxis6"   ] = "-Z Синя"
  tPool["tool."..sTool..".dirlever"   ] = "Направление на рамото"
  tPool["tool."..sTool..".dirlever0"  ] = "<Персонално>"
  tPool["tool."..sTool..".dirlever1"  ] = "+X Червена"
  tPool["tool."..sTool..".dirlever2"  ] = "+Y Зелена"
  tPool["tool."..sTool..".dirlever3"  ] = "+Z Синя"
  tPool["tool."..sTool..".dirlever4"  ] = "-X Червена"
  tPool["tool."..sTool..".dirlever5"  ] = "-Y Зелена"
  tPool["tool."..sTool..".dirlever6"  ] = "-Z Синя"
  tPool["tool."..sTool..".keyfwd"     ] = "Ключ за напред:"
  tPool["tool."..sTool..".keyrev"     ] = "Ключ за назад:"
  tPool["tool."..sTool..".mass"       ] = "Тегло: "
  tPool["tool."..sTool..".power"      ] = "Мощност: "
  tPool["tool."..sTool..".friction"   ] = "Триене: "
  tPool["tool."..sTool..".forcelim"   ] = "Граница на сила: "
  tPool["tool."..sTool..".torqulim"   ] = "Граница на въртящ момент: "
  tPool["tool."..sTool..".lever"      ] = "Дължина на лоста: "
  tPool["tool."..sTool..".levercnt"   ] = "Брой лостове: "
  tPool["tool."..sTool..".radius"     ] = "Радиус на сфера: "
  tPool["tool."..sTool..".resetoffs"  ] = "V Нулирай отместването V"
  tPool["tool."..sTool..".linx"       ] = "Отместване X: "
  tPool["tool."..sTool..".liny"       ] = "Отместване Y: "
  tPool["tool."..sTool..".linz"       ] = "Отместване Z: "
  tPool["tool."..sTool..".angp"       ] = "Отместване тангаж: "
  tPool["tool."..sTool..".angy"       ] = "Отместване азимут: "
  tPool["tool."..sTool..".angr"       ] = "Отместване крен: "
  tPool["tool."..sTool..".drwscale"   ] = "Скала на чертане: "
  tPool["tool."..sTool..".toggle"     ] = "Превключи"
  tPool["tool."..sTool..".nocollide"  ] = "Не-сблъсък с трейса"
  tPool["tool."..sTool..".ghosting"   ] = "Активирай призрака"
  tPool["tool."..sTool..".adviser"    ] = "Активирай съветника"
  tPool["Cleanup_"..sLimit            ] = "Спинъри"
  tPool["Cleaned_"..sLimit            ] = "Всички спинъри са почистени"
  tPool["SBoxLimit_"..sLimit          ] = "Достигнахте границата на създадените спинъри!"
return tPool end
