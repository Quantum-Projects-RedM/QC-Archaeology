fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'QC Archaeology'
quantum_discord 'https://discord.gg/kJ8ZrGM8TS'

version '1.0.0'

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
    'html/index.html',
    'locales/*.json',
    'html/img/**/*.png',
    'html/img/minigame/*.png',
    'html/img/minigame/fossils/*.png',
    'html/img/minigame/*.jpg',
    'html/*.css',
    'html/*.png',
    'html/*.js',
    'html/*.mp3'
}

ui_page 'html/index.html'

lua54 'yes'
