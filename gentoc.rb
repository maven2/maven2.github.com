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

INDEX_HTML = 'index.html'
IGNORE = [ SCRIPT, File.join(ROOT, 'icons'), File.join(ROOT, 'toc.css') ]

EXT_MAP = {
  'rb' => :text,
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

FOOTER = <<END
</ul>
<p>Please visit <a href="http://github.com/maven2/maven2.github.com">http://github.com/maven2</a>
if you would like to publish your GitHub-hosted Maven 2 project on this repository.</p>
</body>
</html>
END

# Toc represents the 'table of contents' of a directory
class Toc < Struct.new(:dir, :subdirs, :filenames)

  # Construct a Toc for the given directory path.
  # Initializes and scans the target directory to build the
  # list of child directories and (relative) filenames.
  def initialize(dir)
    super(dir, [], [])
    scan
  end
  
  # Scan the target directory for child directories
  # and filenames.
  def scan
    Dir.glob(File.join(dir, '*')) { |path|
      next if IGNORE.include?(path)
      
      if FileTest.directory?(path)
        subdirs << path
      else
        filename = File.basename(path)
        next if filename == INDEX_HTML
        filenames << filename
      end
    }
  end

  # Writes out the table of contents as an +index.html+ file
  # in the target directory.
  def write_index_html
    index_html = File.join(dir, INDEX_HTML)
      
    File.open(index_html, 'w') { |html|
      generate(html)
    }
    puts "Generated #{index_html}"
  end

  # The actual method that generates the contents of +index.html+
  def generate(html)
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
      d = File.dirname(dir).unfix(ROOT) + '/'
      html.puts "<p><a href=\"#{d}\" class=\"folder_up\">Up to higher level directory</a></p>"
    end
    html.puts '<ul class="dirlist">'
    subdirs.each { |subdir|
      d = File.basename(subdir)
      html.puts "<li class=\"folder\"><a href=\"#{d}/\">#{d}</a></li>"
    }
    filenames.each { |filename|
      ext = File.extname(filename).unfix('.')
      cl = " class=\"#{EXT_MAP[ext]}\"" if EXT_MAP[ext]
      html.puts "<li#{cl if cl}><a href=\"#{filename}\">#{filename}</a></li>"
    }
    html << FOOTER
  end
end

# MAIN

def gentoc(dir)
  toc = Toc.new(dir)
  toc.subdirs.each { |subdir| gentoc(subdir) }
  toc.write_index_html
end

gentoc(ROOT)
