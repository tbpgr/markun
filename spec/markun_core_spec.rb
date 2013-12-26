# encoding: utf-8
require 'spec_helper'
require 'markun_core'
require 'fileutils'

describe Markun::Core do

  context :init do
    OUTPUT_DSL_TMP_DIR = 'generate_dsl'
    cases = [
      {
        case_no: 1,
        case_title: 'valid case',
        expected_files: [
          Markun::Core::MARKUN_FILE,
        ],
        expected_contents: [
          Markun::Core::MARKUN_TEMPLATE,
        ],
      },
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          markun_core = Markun::Core.new

          # -- when --
          markun_core.init

          # -- then --
          c[:expected_files].each_with_index do |f, index|
            actual = File.read("./#{f}")
            expect(actual).to eq(c[:expected_contents][index])
          end
        ensure
          case_after c

        end
      end

      def case_before(c)
        Dir.mkdir(OUTPUT_DSL_TMP_DIR) unless Dir.exists? OUTPUT_DSL_TMP_DIR
        Dir.chdir(OUTPUT_DSL_TMP_DIR)
      end

      def case_after(c)
        Dir.chdir('../')
        FileUtils.rm_rf(OUTPUT_DSL_TMP_DIR) if Dir.exists? OUTPUT_DSL_TMP_DIR
      end
    end
  end

  context :execute do
    OUTPUT_MARKDOWN_TMP_DIR = 'tmp_markdown'
    MARKUNFILE_CASE1 = <<-EOS
# encoding: utf-8
have_menu "false"
    EOS
    MARKUNFILE_CASE2 = <<-EOS
# encoding: utf-8
have_menu "true"
    EOS

    MARKDOWN1 = <<-EOS
# Title

## Subtitle1
* list1
* list2

## Subtitle2
    EOS

    MARKDOWN2 = <<-EOS
# Title

## Subtitle1
* list1
* list2

~~~
pre1
pre2
~~~

## Subtitle2

---
line

---

    EOS

    cases = [
      {
        case_no: 1,
        case_title: 'flat case',
        markunfile: MARKUNFILE_CASE1,
        inputs_filenames: ['markdown1.md', 'markdown2.md'],
        inputs_contents: [MARKDOWN1, MARKDOWN2],
        expected_files: ['markdown1.html', 'markdown2.html'],
      },
      {
        case_no: 2,
        case_title: 'multi case',
        markunfile: MARKUNFILE_CASE2,
        inputs_filenames: ['markdown1.md', './sub/markdown2.md'],
        inputs_contents: [MARKDOWN1, MARKDOWN2],
        expected_files: ['markdown1.html', './sub/markdown2.html'],
      },
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          markun_core = Markun::Core.new

          # -- when --
          markun_core.execute

          # -- then --
          c[:expected_files].each_with_index do |f, index|
            actual = File.exists?("#{f}")
            expect(actual).to be_true
          end
        ensure
          case_after c

        end
      end

      def case_before(c)
        Dir.mkdir(OUTPUT_MARKDOWN_TMP_DIR) unless Dir.exists? OUTPUT_MARKDOWN_TMP_DIR
        Dir.chdir(OUTPUT_MARKDOWN_TMP_DIR)
        c[:inputs_filenames].each_with_index do |file, index|
          dir = File.dirname(file)
          FileUtils.mkdir_p dir unless File.exists?(dir)
          File.open(file, 'w') { |f|f.print c[:inputs_contents][index] }
        end
        File.open(Markun::Core::MARKUN_FILE, 'w') { |f|f.print c[:markunfile] }
      end

      def case_after(c)
        Dir.chdir('../')
        FileUtils.rm_rf(OUTPUT_MARKDOWN_TMP_DIR) if Dir.exists? OUTPUT_MARKDOWN_TMP_DIR
      end
    end
  end

end
