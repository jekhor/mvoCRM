class Letter
  attr_accessor :subject, :text, :address

  def initialize(options)
    unless options.nil?
      @subject = options[:subject]
      @text = options[:text]
      @address = options[:address]
    end
  end

  def to_pdf
    result = nil
    Dir.mktmpdir(nil, File.join(Rails.root, 'tmp')) do |dir|
      system("cp -vr \"#{Rails.root}/app/letters_templates/default/bikedoc.cls\" \"#{dir}\"")
      system("cp -vr \"#{Rails.root}/app/letters_templates/default/template.tex\" \"#{dir}\"")
      tmpl = File.read(File.join(dir, "template.tex"))
      letter = parse_template(tmpl)
      tex = File.new(File.join(dir, "letter.tex"), "wb")
      tex.write(letter)
      tex.close
           
      system("cd \"#{dir}\"; pdflatex letter.tex")

      result = File.read(File.join(dir, "letter.pdf"))
    end

    result
  end

  private

  def parse_template(tmpl)
    tmpl.gsub("_SUBJECT_", text2tex(@subject)).gsub("_ADDRESS_", text2tex(@address)).gsub("_BODY_", text2tex(@text))
  end

  MAP = {
    "_" => '\_',
    '%' => '\%',
    /^"/ => '«',
    /(\s)"/ => '\1«',
    /([^\s])"/ => '\1»',
    /\n/ => "\n\n",
  }

  def text2tex(text)
    t = text

    MAP.each_pair {|key, val|
      t.gsub!(key, val)
    }

    t
  end
end
