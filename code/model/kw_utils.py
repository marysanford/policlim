#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
__author__ = Mary Sanford
__email__ = mary.sanford@cmcc.it

Utils for climate-relevant keyword detection in all EU languages (galician and catalan missing for the energy, transport, electricity, and extra kw dicts)
Includes function to automate extraction and np implementation of cohen's k

'''

import re, pandas as pd, numpy as np

kw_clim_em_ren_dict = {
    'german':['emission\w*','klima\w*','erneuerbar\w*'],#,'nachhaltig\w*'],
    'dutch':['emiss\w*','uitstoot','klima\w*','hernieuwbare\w*', 'duurzaam\w*'], # duurzaam is renewable and sustainable
    'french':['émission\w*','clima\w*','renouvelable\w*'],#,'durable\w*'],
    'spanish':['emis\w*','clima\w*','climá\w*','renovable\w*'],#,'sostenibil\w*'],
    'english':['emission\w*','clima\w*','renewable\w*'], #,'sustainab\w*'
    'lithuanian':['teršal\w*','išmet\w*','klima\w*','atsinaujinan\w*'],#,'tvaru\w*'],
    'greek':['εκπομπ\w*','κλίμα\w*','ανανεώσιμ\w*'],#,'βιώσιμ\w*'],
    'slovenian':['emis\w*','klima\w*','podneb\w*','obnovljiv\w*'],#'trajnost\w*'],
    'hungarian':['kibocsátás\w*','klím\w*','megújuló\w*'],#,'fenntartható\w*'],
    'portuguese':['emiss\w*','clima\w*','climá\w*','renováv\w*'],#,'sustent\w*'],
    'slovak':['emis\w*','klima\w*','klím\w*','podneb\w*','obnovite\w*'],#'udržate\w*'],
    'polish':['emis\w*','klima\w*','odnawialn\w*'],#'zrównoważony\w*'],
    'czech':['emis\w*','klima\w*','obnoviteln\w*'],#'udržiteln\w*'],
    'croatian':['emisij\w*','klima\w*','obnovljiv\w*'],#'održiv\w*'],
    'finnish':['\w*päästö\w*','ilmast\w*','uusiutuv\w*'],#'kestäv\w*'], # updated pääst to päästö
    'swedish':['utsläp\w*','klima\w*','förnybar\w*'],#,'hållbar\w*'],
    'estonian':['heit\w*','heid\w*','emissioo\w*','kliima\w*','taastuv\w*'],#,'jätkusuutlik\w*'], # may want to remove heid
    'italian':['emission\w*','clima\w*','rinnovabil\w*'],#'sostenibil\w*'],
    'danish':['\w*emiss\w*','klima\w*','vedvarende\w*'],#'bæredygtig\w*'],
    'bulgarian':['емис\w*','климат\w*','възобновяем\w*'],#'устойчив\w*'],
    'romanian':['emis\w*','udlednin\w*','clima\w*','regenerabil\w*'],#'durabil\w*'],
    'latvian':['emis\w*','klima\w*','atjaunoj\w*'],#,'ilgtspēj\w*']
    'catalan':['emissi\w*','clima\w*','renova\w*'],
    'galician':['emisi\w*','clim\w*','renova\w*'],
      'japanese':['気候','再生可能\w*','排出\w*'],
      'hebrew':['\w*אקל\w*','\w*מתחדש\w*','\w*פליטת\w*', '\w*פליטות\w*', '\w*פליטה\w*'],
      'icelandic':['\w*loftslag\w*','endurnýjanleg\w*','*\wútblástur\w*'],
      'korean':['기후\w*','\w*재생 가능\w*','\w*배출\w*'],
      'norwegian':['klima\w*','\w*fornybar\w*','*\wutslipp\w*','emisjon'],
      'turkish':['iklim\w*','yenilenebilir\w*','emisyon\w*','salınımı\w*']
}

kw_sust_env_dict = {
    'bulgarian':['устойчив\w*','околна\w* среда'],
    'croatian':['održiv\w*','okoliš\w*'],
    'czech':['udržiteln\w*','prostředi\w*'],
    'danish':['bæredygtig\w*','miljø\w*'],
    'dutch':['duurzaam\w*','milieu'],
    'english':['sustainab\w*','environment\w*'],
    'estonian':['jätkusuutlik\w*','keskkon\w*'],
    'finnish':['kestäv\w*','ympäristö\w*'],
    'french':['durable\w*','environnement\w*'],
    'german': ['nachhaltig\w*','\w*umwelt\w*'],
    'greek':['βιώσιμ\w*','Περιβάλλ\w*'],
    'hungarian':['fenntartható\w*','környezet\w*'],
    'italian':['sostenibil\w*','\w*ambient\w*'],
    'latvian':['ilgtspēj\w*','vidē','vidi','vides','vide','videi','vidu','vidēm','vidēs'],
    'lithuanian':['tvaru\w*','aplink\w*'],
    'polish':['zrównoważony\w*','środowisk\w*'],
    'portuguese':['sustent\w*','\w*ambient\w*'],
    'romanian':['durabil\w*','mediu\w*'],
    'slovak':['udržate\w*','životné\w* prostredie'],
    'slovenian':['trajnost\w*','okolj\w*'],
    'spanish':['sostenibil\w*','\w*ambient\w*'],
    'swedish':['hållbar\w*','miljö\w*'],
    'catalan':['sostenib\w*','ambient\w*'],
    'galician':['durab\w*','sostib\w*','sustentab\w*','ambient\w*'],
    'japanese':['持続可能\w*','じぞくかのう\w*','環境\w*'],
    'hebrew':['\w*קיימא','\w*סביבה'],
    'icelandic':['sjálfbær\w*','\w*umhverfis\w*'],
    'korean':['지속 가능한\w*','환경\w*'],
    'norwegian':['bærekraft\w*','miljø\w*'],
    'turkish':['sürdürülebilir\w*','çevre\w*','ortam\w*']
}

kw_clim_dict = {
      'catalan':['clim\w*'],
      'galician':['clim\w*'],
      'german':['klima\w*'],#,'nachhaltig\w*'],
      'dutch':['klima\w*'], # duurzaam is renewable and sustainable
      'french':['clima\w*'],#,'durable\w*'],
      'spanish':['clima\w*','climá\w*'],
      'english':['clima\w*'], #,'sustainab\w*'
      'lithuanian':['klima\w*'],#,'tvaru\w*'],
      'greek':['κλίμα\w*'],#,'βιώσιμ\w*'],
      'slovenian':['klima\w*','podneb\w*'],#'trajnost\w*'],
      'hungarian':['klím\w*'],#,'fenntartható\w*'],
      'portuguese':['clima\w*','climá\w*'],#,'sustent\w*'],
      'slovak':['klima\w*','klím\w*','podneb\w*'],#'udržate\w*'],
      'polish':['klima\w*'],#'zrównoważony\w*'],
      'czech':['klima\w*'],#'udržiteln\w*'],
      'croatian':['klima\w*'],#'održiv\w*'],
      'finnish':['ilmast\w*'],#'kestäv\w*'], # updated pääst to päästö
      'swedish':['klima\w*'],#,'hållbar\w*'],
      'estonian':['kliima\w*'],#,'jätkusuutlik\w*'], # may want to remove heid
      'italian':['clima\w*'],#'sostenibil\w*'],
      'danish':['klima\w*'],#'bæredygtig\w*'],
      'bulgarian':['климат\w*'],#'устойчив\w*'],
      'romanian':['clima\w*'],#'durabil\w*'],
      'latvian':['klima\w*'],#,'ilgtspēj\w*'],
      'japanese':['気候'],
      'hebrew':['\w*אקל\w*'],
      'icelandic':['\w*loftslag\w*'],
      'korean':['기후\w*'],
      'norwegian':['klima\w*'],
      'turkish':['iklim\w*']
    
  }

# From Pianta and Sisco 2020: https://github.com/silviapianta/pianta_sisco_2020_climate_change_keywords
kw_climate_change_dict = {
 'bulgarian': ['глобалнl\w* затопляне','climate change'],
 'croatian': ['globalnl\w* zatopljenjl\w*','globalnl\w* zagrijavanjl\w*','globalnl\w* zagrevanjl\w*','climate change'],
 'czech': ['globálnl\w* oteplovánl\w*','climate change'],
 'danish': ['global\w* opvarmninl\w*','climate change'],
 'dutch': ['opwarminl\w* van de aarde','global warming','wereldwijdl\w* opwarminl\w*'],
 'english': ['global warming','climate change'],
 'estonian': ['globaall\w* soojeneml\w*','climate change'],
 'finnish': ['ilmastl\w* lämpeneminl\w*','ilmastl\w* lämpenl\w*','globaall\w* lämpeneminl\w*','maapalll\w* lämpeneminl\w*','climate change'],
 'french': ['réchauffement climatique','réchauffement global','réchauffement mondial','réchauffement de la planète',
  'réchauffement planétaire','réchauffement de la terre','réchauffement du globe','climate change'],
 'german': ['globale erwärmung','globaler erwärmung','globalen erwärmung','globale erderwärmung','globalen erderwärmung',
 'globaler erderwärmung', 'erderwärmung','climate change'],
 'greek': ['παγκόσμl\w* θέρμανσl\w*','παγκόσμl\w* υπερθέρμανσl\w*','θέρμανσl\w* του πλανήτη','υπερθέρμl\w* του πλανήτη','climate change'],
 'hungarian': ['globáll\w* felmelegedl\w*','climate change'],
 'italian': ['riscaldamento globale', 'surriscaldamento globale','climate change'],
 'latvian': ['globāll\w* sasilšanl\w*','climate change'],
 'lithuanian': ['pasaulinl\w* atšiliml\w*','climate change'],
 'polish': ['globall\w* ocieplenl\w*','climate change'],
 'portuguese': ['aquecimento global', 'aquecimento do planeta','climate change'],
 'romanian': ['încălzirl\w* globall\w*','climate change'],
 'slovak': ['globálnl\w* otepľovanl\w*','climate change'],
 'slovenian': ['globalnl\w* segrevanjl\w*', 'segrevanjl\w* ozračjl\w*'],
 'spanish': ['calentamiento global','calentamiento del planeta','recalentamiento global','recalentamiento del planeta','climate change'],
 'swedish': ['global\w* uppvärmnl\w*', 'jordens uppvärmnl\w*','climate change'],
 'catalan':['canvi\w* climàtic\w*','climate change'],
 'galician':['cambio\w* climático\w*','climate change'],
   'japanese':['気候変動','気候変化','きこうへんどう'],
      'hebrew': ['שינוי אקלים'],
      'icelandic':['loftslagsbreytingar','loftslagsbreytinga'],
      'korean':['기후 변화'],
      'norewegian':['klimaendringene\w*','klimaendring\w*','klimaendringer\w*','klimaforskning\w*','klimaforandringer\w*','klimaendringane\w*'],
      'turkish':['iklim değişikliği\w*','iklim değişimi\w*']

  }

# From Pianta and Sisco 2020: https://github.com/silviapianta/pianta_sisco_2020_climate_change_keywords
gw_dict = {
'bulgarian': ['глобалн\w* затопляне'],
 'catalan': ['escalfament global'],
 'croatian': ['globaln\w* zatopljenj\w*','globaln\w* zagrijavanj\w*','globaln\w* zagrevanj\w*'],
 'czech': ['globáln\w* oteplován\w*'],
 'danish': ['globa\w* opvarmnin\w*'],
 'dutch': ['opwarmin\w* van de aarde','global warming','wereldwijd\w* opwarmin\w*'],
 'english': ['global warming'],
 'estonian': ['globaal\w* soojenem\w*'],
 'finnish': ['ilmast\w* lämpenemin\w*','ilmast\w* lämpen\w*','globaal\w* lämpenemin\w*','maapall\w* lämpenemin\w*'],
 'french': ['réchauffement climatique','réchauffement global','réchauffement mondial','réchauffement de la planète',
  'réchauffement planétaire','réchauffement de la terre','réchauffement du globe'],
 'galician':['quecemento global'],
 'german': ['globale erwärmung','globaler erwärmung','globalen erwärmung','globale erderwärmung','globalen erderwärmung',
  'globaler erderwärmung','erderwärmung'],
 'greek': ['παγκόσμ\w* θέρμανσ\w*','παγκόσμ\w* υπερθέρμανσ\w*',
  'θέρμανσ\w* του πλανήτη',
  'υπερθέρμ\w* του πλανήτη',
  'παγκόσμ\w* άνοδ\w* της θερμοκρασίας'],
 'hungarian': ['globál\w* felmeleged\w*'],
 'italian': ['riscaldamento globale', 'surriscaldamento globale'],
 'latvian': ['globāl\w* sasilšan\w*'],
 'lithuanian': ['pasaulin\w* atšilim\w*',
  'visuotin\w* atšilim\w*',
  'globalin\w* atšilim\w*',
  'klimato atšilim\w*'],
 'polish': ['global\w* ocieplen\w*', 'ocieplen\w* global\w*'],
 'portuguese': ['aquecimento global', 'aquecimento do planeta'],
 'romanian': ['încălzir\w* global\w*'],
 'slovak': ['globáln\w* otepľovan\w*'],
 'slovenian': ['globaln\w* segrevanj\w*', 'segrevanj\w* ozračj\w*'],
 'spanish': ['calentamiento global',
  'calentamiento del planeta',
  'recalentamiento global',
  'recalentamiento del planeta',
  'calentamiento de la tierra',
  'calentamiento de la atmósfera',
  'calentamiento atmosférico',
  'recalentamiento de la tierra',
  'recalentamiento de la atmósfera',
  'recalentamiento atmosférico'],
 'swedish': ['globa\w* uppvärmn\w*','jordens uppvärmn\w*','uppvärmn\w* av jorden'],
  'japanese':['地球温暖化','地球規模警報','ちきゅうおんだんか'],
  'hebrew':['התחממות עולמית','התחממות כדור הארץ'],
  'icelandic':['hlýnun jarðar','heimshlýnun','gróðurhúsaáhrifin'],
  'korean':['지구 온난화'],
  'norwegian':['global\w* oppvarming\w*','drivhuseffekt\w*'],
  'turkish':['küresel ısınma\w*','küresel ısınmadan\w*','küresel ısınmanın\w*']  
  }

energy_dict  = {
    'bulgarian':['енер\w*','ядрен\w*'],
    'croatian':['energ\w*'],
    'czech':['energ\w*'],
    'danish':['\w*energ\w*'],
    'dutch':['\w*energ\w*'],
    'english':['energy','energies'],
    'estonian':['\w*energ\w*'],
    'finnish':['\w*energ\w*'],
    'french':['énergie\w*'],
    'german':['\w*energie\w*'],
    'greek':['ενέργει\w*'],
    'hungarian':['\w*energ\w*'],
    'italian':['\w*energ\w*'],
    'latvian':['\w*enerģ\w*'],
    'lithuanian':['\w*energ\w*'],
    'polish':['energ\w*'],
    'portuguese':['\w*energ\w*'],
    'romanian':['\w*energ\w*'],
    'slovak':['\w*energ\w*'],
    'slovenian':['\w*energ\w*'],
    'spanish':['\w*energ\w*'],
    'swedish':['\w*energ\w*']
}

transport_dict  = {
    'bulgarian':['превоз\w*','транспор\w*'],
    'croatian':['promet\w*','prije\w*'],
    'czech':['přeprav\w*','doprav\w*'],
    'danish':['\w*transport\w*','nærtrafik'],
    'dutch':['\w*transport\w*','\w*vervoer\w*'],
    'english':['transport\w*'],
    'estonian':['\w*transpor\w*'],
    'finnish':['\w*kuljet\w*','\w*liiken\w*'],
    'french':['transport\w*'],
    'german':['\w*transport\w*','\w*verkehr\w*'],
    'greek':['μεταφορ\w*'],
    'hungarian':['szállít\w*','\w*fuvarozás\w*','\w*közlekedés\w*'],
    'italian':['trasport\w*'],
    'latvian':['\w*transport\w*','\w*satiks\w*'],
    'lithuanian':['\w*transport\w*','\w*gaben\w*'],
    'polish':['\w*transpor\w*','\w*środk\w*','\w*przew\w*'],
    'portuguese':['\w*transport\w*'],
    'romanian':['\w*transport\w*'],
    'slovak':['\w*transport\w*','\w*doprav\w*','\w*prepav\w*'],
    'slovenian':['\w*transport\w*','\w*prevoz\w*','\w*promet\w*'],
    'spanish':['\w*transport\w*'],
    'swedish':['\w*transport\w*','\w*trafik\w*']
}

electricity_dict = {
    'bulgarian':['\w*електр\w*'],
    'croatian':['\w*elektr\w*','\w*struj\w*'],
    'czech':['\w*elektr\w*'],
    'danish':['\w*elektr\w*','\w*strøm\w*','elomkosting\w*'],
    'dutch':['\w*elektr\w*','\w*stroom\w*'],
    'english':['\w*electric\w*'],
    'estonian':['\w*elektri\w*','elektro\w*'],
    'finnish':['\w*sähkö\w*'],
    'french':['\w*électri\w*'],
    'german':['\w*elektr\w*','\w*strom\w*'],
    'greek':['\w*ηλεκτρ\w*'],
    'hungarian':['\w*elektr\w*','\w*villamos\w*','\w*villany\w*','\w*áram\w*'],
    'italian':['\w*elettric\w*'],
    'latvian':['\w*elektr\w*'],
    'lithuanian':['\w*elektr\w*'],
    'polish':['\w*elektr\w*'],
    'portuguese':['\w*eletric\w*','\w*elétric\w*'],
    'romanian':['\w*electr\w*'],
    'slovak':['\w*elektr\w*'],
    'slovenian':['\w*elektr\w*'],
    'spanish':['\w*electr\w*','\w*eléctr\w*'],
    'swedish':['\w*elektr\w*','elkostnad\w*','elförbrukning','elvolymer','elmotor\w*','elförsörjning','elkris\w*','elbilar\w*']
}

extra_kw_dict = {
    'bulgarian':['енер\w*','ядрен\w*','аmомн\w*','атомн\w*','газ','въглерод\w*','изкопаем\w*','Фосилн\w*'],
    #             energy    energy     nuclear    nuclear    gas     carbon         fossil fuels           fossil fuels
    'croatian':['energ\w*','\w*nuklear\w*','\w*plin\w*','\w*uglj\w*','fosil\w*'],
    #            energy    nuclear/denuclear   gas          carbon     fossil fuels
    'czech':['energ\w*','jadern\w*','nukleár\w*','denuklear\w*','plyn\w*','\w*uhlí\w*','fosil\w*'],
    #          energy    nuclear                   denuclear      gas        carbon      fossil fuels
    'danish':['\w*energ\w*','\w*kern\w*','\w*nuklear\w*','\w*gas\w*','\w*kul\w*','\w*carbon\w*','fossil\w*'],
    'dutch':['\w*energ\w*','\w*kern\w*','\w*nucleair\w*','\w*gas\w*','\w*kool\w*','fossiel\w* brandstoff\w*'],
    'english':['energy','energies','\w*nuclear\w*','gas','\w*carbon\w*','fossil\w*'],
    'estonian':['\w*energ\w*','tuuma\w*','denuklear\w*','\w*gaas\w*','\w*süsi\w*','fossiil\w*'],
    #            energy          nuclear     denulcear     gas          carbon      fossil fuels
    'finnish':['\w*energ\w*','ydin\w*','\w*kaas\w*','\w*hiili\w*','fossiil\w*'],
    #            energy      de/nuclear  gas          carbon        fossil fuels
    'french':['énergie\w*','\w*nucléaire\w*','dénucléar\w*','gaz','\w*charbon\w*','\w*carbon\w*','fossil\w*'],
    'german':['\w*energie\w*','\w*kern\w*','\w*nuklear\w*','\w*gas','\w*kohl\w*','\w*karbon\w*','fossil\w*'],
    'greek':['ενέργει\w*','\w*πυρηνικ\w*','πετρέλαιο\w*','αερί\w*','\w*ανθρακ\w*','\w*άνθρακ\w*'],
    #           energy          nulcear         gas                 carbon            fossil
    'hungarian':['\w*energ\w*','\w*atom\w*','\w*nukleár\w*','\w*gáz\w*','\w*szén\w*','fosszil\w*'],
    #                energy         nuclear                     gas        carbon      fossil
    'italian':['\w*energ\w*','\w*nuclear\w*','atomic\w*','\w*gas\w*','\w*carbon\w*','fossil\w*'],
    'latvian':['\w*enerģ\w*','\w*nuklear\w*','\w*kodol\w*','\w*gāz\w*','\w*oglek\w*','fosil\w*'],
    'lithuanian':['\w*energ\w*','branduol\w*','nuklear\w*','duj\w*','\w*angli\w*','iškastin\w*'],
    #               energy         nulcear/denuclear         gas      carbon      fossil fuel
    'polish':['energ\w*','\w*nuklear\w*','jądrow\w*','\w*węg\w*','pali\w* kopaln\w*'], # verify
    #            energy      nuclear        gas         carbon    fossil fuels
    'portuguese':['\w*energ\w*','\w*nuclear\w*','gás\w*','gas\w*','\w*carbon\w*','fósseis\w*','fóssil\w*'],
    'romanian':['\w*energ\w*','\w*nuclear\w*','\w*gaz\w*','\w*carbon\w*','fosil\w*'],
    'slovak':['\w*energ\w*','jadrov\w*','nukleár\w*','denukle\w*','\w*plyn\w*','\w*spalín\w*','fosíln\w*'],
    'slovenian':['\w*energ\w*','jedr\w*','\w*nuklear\w*','\w*plin\w*','\w*ogljik\w*','fosiln\w*'],
    'spanish':['\w*energ\w*','\w*nuclear\w*','gas\w*','\w*carbon\w*','\w*carbón\w*','fósil\w*'],
    'swedish':['\w*energ\w*','\w*nukleär\w*','\w*kärn\w*','gas\w*','\w*kol\w*','fossil\w*']
}

noneu_oecd_dict = {
    'turkish': ['iklim değişikliği\w*','iklim değişimi\w*','küresel ısınma\w*','küresel ısınmadan\w*','küresel ısınmanın\w*'],
    'norwegian':['klimaendringene\w*','klimaendring\w*','klimaendringer\w*','klimaforskning\w*','klimaforandringer\w*','klimaendringane\w*',
                  'global\w* oppvarming\w*','drivhuseffekt\w*','klima\w*','\w*fornybar\w*','\w*utslipp\w*','emisjon\w* bærekraftig\w*',
                  'bærekraft\w*','miljø\w*'],
    'korean': ['기후 변화','지구 온난화','기후\w*','\w*재생 가능\w*','\w*배출\w*','지속 가능한\w*','환경\w*'],  
    'hebrew': ['שינוי אקלים','התחממות עולמית','התחממות כדור הארץ','\w*אקל','\w*מתחדש\w*',
               '\w*פליטת\w*', '\w*פליטות\w*', '\w*פליטה\w*','\w*קיימא\w*','\w*סביבה\w*'],
    'icelandic': ['loftslagsbreytingar','loftslagsbreytinga','hlýnun jarðar','heimshlýnun',
                  'gróðurhúsaáhrifin','\w*loftslag\w*','endurnýjanleg\w*','\w*útblástur\w*','sjálfbær\w*',
                  '\w*umhverfis\w*'],
    'japanese': ['気候変動','気候変化','きこうへんどう','地球温暖化','地球規模警報','ちきゅうおんだんか','気候',
                 '再生可能\w*','排出\w*','持続可能\w*','じぞくかのう\w*','環境\w*']
}

def get_kw(dict_name):
    if dict_name == 'clim_em_ren':
        return(kw_clim_em_ren_dict)
    elif dict_name == 'sust_env':
        return(kw_sust_env_dict)
    elif dict_name == 'energy_dict':
        return(energy_dict)
    elif dict_name == 'transport_dict':
        return(transport_dict)
    elif dict_name == 'electricity_dict':
        return(electricity_dict)
    elif dict_name == 'climate_change_dict':
        return(kw_climate_change_dict)
    elif dict_name == 'gw_dict':
        return(gw_dict)
    elif dict_name == 'climate_dict':
        return(kw_clim_dict)
    elif dict_name == 'extra':
        return(extra_kw_dict)
    elif dict_name == 'noneu_oecd':
        return(noneu_oecd_dict)
    else:
        print('Dictionary name not recognised.')
        return()

# Function to extract the keywords
def extract_keywords(texts, kw, check=False, list=False):
    # set list boolean to True to process lists of strings, false to process single strings
    # set check to True to examine kw regex patterns

    pattern = re.compile(r'\b(' + '|'.join(kw) + r')\b')
    if check:
        print(pattern)

    if list:
        found = []

        for n,string in enumerate(texts):
            words = pattern.findall(string.lower())
            if len(words) > 0:
                found.append(1)
            else:
                found.append(0)

        return found

    else:
        words = pattern.findall(texts.lower())
        if len(words) > 0:
            return 1
        else:
            return 0

def cohen_k(conf):
    # source code for sklearn's cohen_kappa_score: https://github.com/scikit-learn/scikit-learn/blob/5c4aa5d0d/sklearn/metrics/_classification.py#L617
    # pd cross tab MUST be wrapped in np array
    conf = np.array(conf)
    n_classes = conf.shape[0]
    sum0 = np.sum(conf, axis=0)
    sum1 = np.sum(conf, axis=1)

    expected = np.outer(sum0, sum1) / np.sum(sum0)

    w_mat = np.ones([n_classes, n_classes], dtype=int)
    w_mat.flat[:: n_classes + 1] = 0

    k = np.sum(w_mat * conf) / np.sum(w_mat * expected)
    return(1-k)
