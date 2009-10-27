#!/usr/bin/env ruby

INDEX_HTML = 'index.html'

FOOTER=<<END
</ul>
</body>
</html>
END

# MAIN

ROOT, SCRIPT=File.split($0)

def gentoc(base)
  puts base
  files = []
  dirs = []
  Dir.foreach(base) { |path|
    fq = File.join(base, path)
    if FileTest.directory?(fq)
      next if path[0, 1] == '.'
      dirs << path
    else
      next if path == SCRIPT || path == INDEX_HTML
      files << path
    end
  }
  dirs.each { |dir| gentoc(File.join(base, dir)) }
  write_index_html(base, dirs, files)
end

def write_index_html(base, dirs, files)
  index = File.join(base, INDEX_HTML)
  title = File.basename(base)
  File.open(index, 'w') { |o|
    o << <<END
<html>
<title>#{title}</title>
<body>
<h1>Maven2 GitHub repository</h1>
<p>Please visit <a href="http://github.com/maven2">http://github.com/maven2</a> if you would like to publish your GitHub-hosted Maven 2 project on this repository.</p>
<ul>
END
    dirs.each { |dir|
      b = File.basename(dir)
      o.puts "<li><a href=\"#{b}/\">#{b}</a></li>"
    }
    files.each { |file| o.puts "<li>#{File.basename(file)}</li>" }
    o << FOOTER
  }
end

gentoc(ROOT)
