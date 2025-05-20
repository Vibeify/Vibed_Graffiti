fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Graffiti System for FiveM - Create tags and claim territory'
version '1.0.0'

shared_script 'config.lua'
server_script 'server.lua'
client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/graffiti.html',
    'html/fonts/*.ttf',
    'html/images/*.png'
}