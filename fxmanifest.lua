fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'A Archeology script with a custom minigame and tracking of all bones in RDR3 for dinosaurs'
author 'Artmines- Quantum Projects Lead'
quantum_discord 'https://discord.gg/kJ8ZrGM8TS'

version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/client.lua'
}

server_scripts { 
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/versionchecker.lua'
}

dependencies {
    'rsg-core',
    'ox_lib',
}

files {
    'html/dist/index.html',
    'locales/*.json',
    'html/dist/img/**/*.png',
    'html/dist/img/minigame/*.png',
    'html/dist/img/minigame/fossils/*.png',
    'html/dist/img/minigame/*.jpg',
    'html/dist/img/archeology_book/*.png',
    'html/dist/*.js',
    'html/dist/*.mp3',
    'html/dist/*.png'
}

ui_page 'html/dist/index.html'

lua54 'yes'
