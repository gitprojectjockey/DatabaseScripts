declare @json nvarchar(max) =
'
[
  {
    "name": "REMOTION",
    "email": "tuckerwatson@remotion.com",
    "phone": "+1 (949) 457-3586"
  },
  {
    "name": "GOLOGY",
    "email": "carmenwatson@gology.com",
    "phone": "+1 (976) 543-2314"
  },
  {
    "name": "EPLOSION",
    "email": "wileywatson@eplosion.com",
    "phone": "+1 (863) 489-2122"
  },
  {
    "name": "VENDBLEND",
    "email": "kanewatson@vendblend.com",
    "phone": "+1 (876) 431-2134"
  },
  {
    "name": "EXIAND",
    "email": "blanchardwatson@exiand.com",
    "phone": "+1 (898) 413-3473"
  },
  {
    "DONOTINCLUDE": "Britney EXTRAGEN",
    "name": "ROCKABYE",
    "email": "britneywatson@rockabye.com",
    "phone": "+1 (878) 600-3095"
  },
  {
    "DONOTINCLUDE": "Alissa UNCORP",
    "name": "ZAPHIRE",
    "email": "alissawatson@zaphire.com",
    "phone": "+1 (960) 569-2027"
  },
  {
    "DONOTINCLUDE": "Stark CODACT",
    "name": "ECOSYS",
    "email": "starkwatson@ecosys.com",
    "phone": "+1 (820) 554-3415"
  },
  {
    "DONOTINCLUDE": "Allison BLANET",
    "name": "GEEKOLOGY",
    "email": "allisonwatson@geekology.com",
    "phone": "+1 (970) 448-2820"
  },
  {
    "DONOTINCLUDE": "Shauna IMANT",
    "name": "PULZE",
    "email": "shaunawatson@pulze.com",
    "phone": "+1 (981) 597-3754"
  },
  {
    "DONOTINCLUDE": "Helga DELPHIDE",
    "name": "NETPLAX",
    "email": "helgawatson@netplax.com",
    "phone": "+1 (901) 496-3464"
  },
  {
    "DONOTINCLUDE": "Moran PYRAMIA",
    "name": "IDEGO",
    "email": "moranwatson@idego.com",
    "phone": "+1 (840) 485-2931"
  },
  {
    "DONOTINCLUDE": "Jodie MAGNEATO",
    "name": "EXTRO",
    "email": "jodiewatson@extro.com",
    "phone": "+1 (970) 441-2564"
  },
  {
    "DONOTINCLUDE": "Best VALPREAL",
    "name": "NAVIR",
    "email": "bestwatson@navir.com",
    "phone": "+1 (994) 579-2108"
  },
  {
    "DONOTINCLUDE": "Constance TALAE",
    "name": "NEPTIDE",
    "email": "constancewatson@neptide.com",
    "phone": "+1 (973) 516-2847"
  },
  {
    "DONOTINCLUDE": "Mendez ADORNICA",
    "name": "KRAG",
    "email": "mendezwatson@krag.com",
    "phone": "+1 (881) 545-3232"
  },
  {
    "DONOTINCLUDE": "Gilbert MOLTONIC",
    "name": "INCUBUS",
    "email": "gilbertwatson@incubus.com",
    "phone": "+1 (859) 473-2978"
  },
  {
    "DONOTINCLUDE": "Workman EXOZENT",
    "name": "CAXT",
    "email": "workmanwatson@caxt.com",
    "phone": "+1 (993) 461-3664"
  },
  {
    "DONOTINCLUDE": "Rios NIPAZ",
    "name": "GINKLE",
    "email": "rioswatson@ginkle.com",
    "phone": "+1 (941) 437-3984"
  },
  {
    "DONOTINCLUDE": "Bush ISOPOP",
    "name": "RENOVIZE",
    "email": "bushwatson@renovize.com",
    "phone": "+1 (812) 423-2176"
  },
  {
    "DONOTINCLUDE": "Mcintosh PORTALIS",
    "name": "EVENTAGE",
    "email": "mcintoshwatson@eventage.com",
    "phone": "+1 (826) 479-2048"
  },
  {
    "DONOTINCLUDE": "Langley MOBILDATA",
    "name": "CONJURICA",
    "email": "langleywatson@conjurica.com",
    "phone": "+1 (862) 598-2563"
  },
  {
    "DONOTINCLUDE": "Mccall AMTAS",
    "name": "DIGINETIC",
    "email": "mccallwatson@diginetic.com",
    "phone": "+1 (917) 549-2465"
  },
  {
    "DONOTINCLUDE": "Ford SKYPLEX",
    "name": "SHOPABOUT",
    "email": "fordwatson@shopabout.com",
    "phone": "+1 (892) 406-3793"
  },
  {
    "DONOTINCLUDE": "Glenda BUZZWORKS",
    "name": "ZOMBOID",
    "email": "glendawatson@zomboid.com",
    "phone": "+1 (940) 510-2241"
  },
  {
    "DONOTINCLUDE": "Albert CONFRENZY",
    "name": "FANGOLD",
    "email": "albertwatson@fangold.com",
    "phone": "+1 (887) 537-3749"
  },
  {
    "DONOTINCLUDE": "Buckley EXOSIS",
    "name": "BICOL",
    "email": "buckleywatson@bicol.com",
    "phone": "+1 (952) 486-2208"
  },
  {
    "DONOTINCLUDE": "Davidson UNEEQ",
    "name": "BOLAX",
    "email": "davidsonwatson@bolax.com",
    "phone": "+1 (967) 582-2799"
  },
  {
    "DONOTINCLUDE": "Jessica INTERODEO",
    "name": "XINWARE",
    "email": "jessicawatson@xinware.com",
    "phone": "+1 (916) 569-2348"
  },
  {
    "DONOTINCLUDE": "Mara VIAGRAND",
    "name": "HONOTRON",
    "email": "marawatson@honotron.com",
    "phone": "+1 (945) 421-2875"
  },
  {
    "DONOTINCLUDE": "Irma GEEKOL",
    "name": "PREMIANT",
    "email": "irmawatson@premiant.com",
    "phone": "+1 (939) 580-2511"
  },
  {
    "DONOTINCLUDE": "Joan FLYBOYZ",
    "name": "EWAVES",
    "email": "joanwatson@ewaves.com",
    "phone": "+1 (962) 558-2121"
  },
  {
    "DONOTINCLUDE": "Tami DANCERITY",
    "name": "CHORIZON",
    "email": "tamiwatson@chorizon.com",
    "phone": "+1 (809) 578-3141"
  },
  {
    "DONOTINCLUDE": "Jimenez EMOLTRA",
    "name": "NSPIRE",
    "email": "jimenezwatson@nspire.com",
    "phone": "+1 (828) 433-3126"
  },
  {
    "DONOTINCLUDE": "Lauren ASSISTIX",
    "name": "DIGIRANG",
    "email": "laurenwatson@digirang.com",
    "phone": "+1 (833) 466-2954"
  },
  {
    "DONOTINCLUDE": "Cline OPTICALL",
    "name": "XYQAG",
    "email": "clinewatson@xyqag.com",
    "phone": "+1 (972) 471-3663"
  },
  {
    "DONOTINCLUDE": "Kirsten CINCYR",
    "name": "GEEKUS",
    "email": "kirstenwatson@geekus.com",
    "phone": "+1 (968) 551-3854"
  },
  {
    "DONOTINCLUDE": "Ana SILODYNE",
    "name": "BIOHAB",
    "email": "anawatson@biohab.com",
    "phone": "+1 (975) 470-3721"
  },
  {
    "DONOTINCLUDE": "Battle GAZAK",
    "name": "INSURITY",
    "email": "battlewatson@insurity.com",
    "phone": "+1 (832) 570-3803"
  },
  {
    "DONOTINCLUDE": "Mcmahon COGENTRY",
    "name": "STUCCO",
    "email": "mcmahonwatson@stucco.com",
    "phone": "+1 (971) 476-3509"
  },
  {
    "DONOTINCLUDE": "Paige VOLAX",
    "name": "GEEKNET",
    "email": "paigewatson@geeknet.com",
    "phone": "+1 (922) 523-2125"
  },
  {
    "DONOTINCLUDE": "Lowery MULTIFLEX",
    "name": "ZBOO",
    "email": "lowerywatson@zboo.com",
    "phone": "+1 (927) 432-2958"
  },
  {
    "DONOTINCLUDE": "Sullivan MUSAPHICS",
    "name": "ASSISTIA",
    "email": "sullivanwatson@assistia.com",
    "phone": "+1 (918) 519-2069"
  },
  {
    "DONOTINCLUDE": "Diana SOLAREN",
    "name": "WAAB",
    "email": "dianawatson@waab.com",
    "phone": "+1 (886) 482-3475"
  },
  {
    "DONOTINCLUDE": "Holcomb CEDWARD",
    "name": "INTERLOO",
    "email": "holcombwatson@interloo.com",
    "phone": "+1 (974) 439-2751"
  },
  {
    "DONOTINCLUDE": "Puckett UNQ",
    "name": "EARWAX",
    "email": "puckettwatson@earwax.com",
    "phone": "+1 (981) 462-3677"
  },
  {
    "DONOTINCLUDE": "Ortega PAPRIKUT",
    "name": "AVENETRO",
    "email": "ortegawatson@avenetro.com",
    "phone": "+1 (853) 507-3190"
  },
  {
    "DONOTINCLUDE": "Sharlene ISOTRONIC",
    "name": "ECSTASIA",
    "email": "sharlenewatson@ecstasia.com",
    "phone": "+1 (983) 462-3423"
  },
  {
    "DONOTINCLUDE": "Miles STEELTAB",
    "name": "ANOCHA",
    "email": "mileswatson@anocha.com",
    "phone": "+1 (962) 582-3716"
  },
  {
    "DONOTINCLUDE": "Payne FIREWAX",
    "name": "TRIPSCH",
    "email": "paynewatson@tripsch.com",
    "phone": "+1 (995) 509-3971"
  }
]
'
 

 INSERT INTO Company 
 (Name,Email,Phone)  
 select name,email,phone FROM OPENJSON(@json)
 WITH (
	   name nvarchar(200), 
	   email  nvarchar(200), 
	   phone nvarchar(50)
	   );


