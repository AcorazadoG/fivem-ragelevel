resource_manifest_version "05cfa83c-a124-4cfa-a768-c24a5811d8f9"

client_script 'warmenu.lua'
client_script 'client.lua'
server_script 'server.lua'


ui_page('html/index.html')

files {
    'html/index.html',
    'html/script.js',
    'html/style.css'
}