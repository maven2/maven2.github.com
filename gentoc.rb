#!/usr/bin/env ruby

ROOT=`pwd`.chomp
SCRIPT=File.join(ROOT, File.basename($0))

SITE = '/maven2.github.com'

INDEX_HTML = 'index.html'
IGNORE = [ SCRIPT, File.join(ROOT, 'icons') ]

EXT_MAP = {
  'java' => :text,
  'pom' => :markup,
  'xml' => :markup,
  'jar' => :zip,
  'sha1' => :text,
  'md5' => :text
}

FOOTER=<<END
</ul>
<p>Please visit <a href="http://github.com/maven2">http://github.com/maven2</a> if you would like to publish your GitHub-hosted Maven 2 project on this repository.</p>
</body>
</html>
END

# MAIN

def gentoc(base)
  files = []
  dirs = []
  Dir.foreach(base) { |path|
    fqpath = File.join(base, path)
    next if IGNORE.include? fqpath
    
    if FileTest.directory?(fqpath)
      next if path[0, 1] == '.'
      dirs << path
    else
      next if File.basename(path) == INDEX_HTML
      files << path
    end
  }
  dirs.each { |dir| gentoc(File.join(base, dir)) }
  write_index_html(base, dirs, files)
end

def write_index_html(base, dirs, files)
  puts "base: #{base}"
  index = File.join(base, INDEX_HTML)
  l = base.length - ROOT.length - 1
  title = 'Index of ' + (base[-l, l] || '/')
    
  File.open(index, 'w') { |o|
    o << <<END
<html>
<head>
<title>#{title}</title>
<link rel="stylesheet" href="/toc.css" />
</head>
<body>
<h3>#{title}</h3>
<ul>
END
    unless base == ROOT
      parent = File.dirname(base).gsub(ROOT, '') + '/'
      o.puts "<li><a href=\"#{parent}\">..</a></li>"
    end
    dirs.each { |dir|
      d = File.basename(dir)
      o.puts "<li class=\"folder\"><a href=\"#{d}/\">#{d}</a></li>"
    }
    files.each { |file|
      f = File.basename(file)
      ext = File.extname(f)
      ext[0, 1] = ''
      cl = EXT_MAP[ext]
      if cl
        o.puts "<li class=\"#{cl}\"><a href=\"#{f}\">#{f}</a></li>"
      else
        o.puts "<li><a href=\"#{f}\">#{f}</a></li>"
      end
    }
    o << FOOTER
  }
end

gentoc(ROOT)
