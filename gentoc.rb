#!/usr/bin/env ruby
#
# Copyright (c) 2009 Alistair A. Israel
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

PWD=Dir.pwd
Dir.chdir(File.dirname($0))

ROOT=Dir.pwd
SCRIPT=File.join(ROOT, File.basename($0))

SITE = '/maven2.github.com'

INDEX_HTML = 'index.html'
IGNORE = [ SCRIPT, File.join(ROOT, 'icons'), File.join(ROOT, 'toc.css') ]

EXT_MAP = {
  'java' => :text,
  'pom' => :markup,
  'xml' => :markup,
  'jar' => :zip,
  'sha1' => :text,
  'md5' => :text
}

class String
  def unfix(prefix, empty='')
    if prefix.length >= length
      empty
    else
      slice(prefix.length, length)
    end
  end
end

# MAIN

def gentoc(dir)
  files = []
  subdirs = []
  Dir.glob(File.join(dir, '*')) { |path|
    next if IGNORE.include?(path)
    
    if FileTest.directory?(path)
      subdirs << path
    else
      filename = File.basename(path)
      next if filename == INDEX_HTML
      files << filename
    end
  }
  subdirs.each { |subdir| gentoc(subdir) }
  write_index_html(dir, subdirs, files)
end

def write_index_html(dir, subdirs, files)
  index_html = File.join(dir, INDEX_HTML)
    
  File.open(index_html, 'w') { |html|
    generate(html, dir, subdirs, files)
  }
  puts "Generated #{index_html}"
end

FOOTER=<<END
</ul>
<p>Please visit <a href="http://github.com/maven2/maven2.github.com">http://github.com/maven2</a>
if you would like to publish your GitHub-hosted Maven 2 project on this repository.</p>
</body>
</html>
END

def generate(html, dir, subdirs, files)
  title = 'Index of ' + dir.unfix(ROOT, '/')
  header = <<END
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>#{title}</title>
<link rel="stylesheet" href="/toc.css" />
</head>
<body>
<h3>#{title}</h3>
END

  html << header
  unless dir == ROOT
    dir = File.dirname(dir).unfix(ROOT) + '/'
    html.puts "<p><a href=\"#{dir}\" class=\"folder_up\">Up to higher level directory</a></p>"
  end
  html.puts '<ul class="dirlist">'
  subdirs.each { |subdir|
    d = File.basename(subdir)
    html.puts "<li class=\"folder\"><a href=\"#{d}/\">#{d}</a></li>"
  }
  files.each { |file|
    f = File.basename(file)
    ext = File.extname(f).unfix('.')
    cl = EXT_MAP[ext]
    if cl
      html.puts "<li class=\"#{cl}\"><a href=\"#{f}\">#{f}</a></li>"
    else
      html.puts "<li><a href=\"#{f}\">#{f}</a></li>"
    end
  }
  html << FOOTER
end

gentoc(ROOT)
