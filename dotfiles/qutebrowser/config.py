# from dracula import blood
# blood(c, {
#     'spacing': {
#         'vertical': 6,
#         'horizontal': 8
#     }
# })

config.load_autoconfig(False)
# c.content.user_stylesheets = ["~/.config/qutebrowser/styles/black.css"]

# 禁用 GPU 渲染
# c.qt.force_software_rendering = 'chromium'

import catppuccin
config.load_autoconfig()
catppuccin.setup(c, 'mocha', True)

# 允许弹窗
c.content.javascript.can_open_tabs_automatically = True

config.source('bindings.py')

c.editor.command = ['kitty', '-T', 'nvimAnywhere', '-e', 'nvim', '{file}', '-c', 'normal {line}G{column0}l']

fileChooser = ['kitty', '-T', 'Floating_Term', '-e', 'fish', '-c', 'yazi --chooser-file="$argv[1]"', '--', '{}']
c.fileselect.handler = "external"
c.fileselect.folder.command = fileChooser
c.fileselect.multiple_files.command = fileChooser
c.fileselect.single_file.command = fileChooser

c.zoom.levels = ["25%", "33%", "50%", "67%", "75%", "90%", "100%", "110%", "120%", "130%", "140%", "150%", "175%", "200%", "250%", "300%"]

# c.url.start_pages = 'file:///dev/null'
# c.url.default_page= 'file:///dev/null'
c.tabs.last_close = "startpage"
c.auto_save.session = False


c.tabs.show = "always"
c.tabs.position = "right"
c.tabs.padding = {"bottom":7, "left":0, "right":0, "top":7}
c.tabs.indicator.width = 0
c.tabs.width = '7%'
c.statusbar.show = "always"
c.completion.height = '30%'

c.keyhint.delay = 0
c.hints.uppercase = False
c.hints.chars = "artdhneioplvmcx"

c.downloads.location.directory = "~/Downloads/"
c.downloads.location.prompt = False
c.downloads.location.suggestion = 'both'
c.downloads.location.remember = False
c.downloads.remove_finished = 3300
c.downloads.position = "bottom"

c.content.fullscreen.window = False # Limit fullscreen to browser window
c.content.blocking.enabled = True
c.content.blocking.method = 'both'
c.content.blocking.adblock.lists = [
  "https://easylist.to/easylist/easylist.txt",
  "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
  "https://easylist.to/easylist/easyprivacy.txt",
  "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
  "https://anti-ad.net/easylist.txt"]

c.scrolling.smooth = True
c.content.autoplay = True

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = 'never'
c.colors.webpage.bg = '#282a36' # fix darkmode white flash
config.set('colors.webpage.darkmode.enabled', False, 'https://giantesswaltz.org') # disable darkmode for gw
config.set('colors.webpage.darkmode.enabled', False, 'https://cloud.oppo.com')

c.content.headers.user_agent = "Mozilla/5.0 ({os_info}; rv:135.0) Gecko/20100101 Firefox/135"
config.set(
    'content.headers.user_agent',
    'Mozilla/5.0 ({os_info}; rv:135.0) Gecko/20100101 Firefox/135',
    pattern='https://accounts.google.com/*'
)
c.scrolling.bar = 'always'
c.hints.selectors["all"].extend([".qutebrowser-custom-click"])
c.hints.selectors["ytskip"] = [".ytp-skip-ad-button.ytp-ad-component--clickable"] # hint the youtube skip ad button

prev_regexes_list = [
    r"\b上一封\b",
    r"\b上页\b",
    r"\b上一页\b",
    r"\b上一章\b",
    r"\b前一页\b",
    r"\b上一张\b",
    r"\bolder\b",
    r"\b‹\b",
    r"\b«\b",
]
next_regexes_list = [
    r"\b下一封\b",
    r"\b下页\b",
    r"\b下一页\b",
    r"\b下一章\b",
    r"\b后一页\b",
    r"\b下一张\b",
    r"\bnewer\b",
    r"\b›\b",
    r"\b»\b",
]
c.hints.prev_regexes.extend(prev_regexes_list)
c.hints.next_regexes.extend(next_regexes_list)

c.aliases = {
        "cs": "config-source",
        "q": "close",
        "qa": "quit",
        "w": "session-save",
        "wq": "quit --save",
        "waq": "quit --save",
        "sp": "spawn -u qute-speed",
        "spu": "spawn -u qute-speed 1.5",
        "msg": "messages",
        "clr": "clear-messages"
}
