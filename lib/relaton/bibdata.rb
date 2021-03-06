require "date"

module Relaton
  class Bibdata
    ATTRIBS = %i[
      docidentifier
      doctype
      title
      stage
      relation
      xml
      pdf
      doc
      html
      uri
      rxl
      revdate
      abstract
      technical_committee
      copyright_from
      copyright_owner
      contributor_author_role
      contributor_author_organization
      contributor_publisher_role
      contributor_publisher_organization
      language
      script
      edition
      datetype
    ]

    attr_accessor *ATTRIBS

    def self.ns(xpath)
      xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1").
        gsub(%r{::([a-zA-z])}, "::xmlns:\\1").
        gsub(%r{\[([a-zA-z][a-z0-9A-Z@/]* ?=)}, "[xmlns:\\1").
        gsub(%r{\[([a-zA-z][a-z0-9A-Z@/]*\])}, "[xmlns:\\1")
    end

    def initialize(options)
      options.each_pair do |k,v|
        send("#{k.to_s}=", v)
      end
      self
    end

    # From http://gavinmiller.io/2016/creating-a-secure-sanitization-function/
    FILENAME_BAD_CHARS = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', '.', ' ' ]

    def docidentifier_code
      return "" if docidentifier.nil?
      a = FILENAME_BAD_CHARS.inject(docidentifier.downcase) do |result, bad_char|
        result.gsub(bad_char, '-')
      end
    end

    DOC_NUMBER_REGEX = /([\w\/]+)\s+(\d+):?(\d*)/
    def doc_number
      docidentifier&.match(DOC_NUMBER_REGEX) ? $2.to_i : 999999
    end

    def self.from_xml(source)

      # bib.relaton_xml_path = URI.escape("#{relaton_root}/#{id_code}.xml")
      revdate = source.at(ns("./date[@type = 'published']")) ||
        source.at(ns("./date[@type = 'circulated']")) || source.at(ns("./date"))
      datetype = "circulated"
      datetype = revdate["type"] if revdate

      new({
        uri: source.at(ns("./uri[not(@type)]"))&.text,
        xml: source.at(ns("./uri[@type='xml']"))&.text,
        pdf: source.at(ns("./uri[@type='pdf']"))&.text,
        html: source.at(ns("./uri[@type='html']"))&.text,
        rxl: source.at(ns("./uri[@type='rxl']"))&.text,
        doc: source.at(ns("./uri[@type='doc']"))&.text,
        docidentifier: source.at(ns("./docidentifier"))&.text,
        title: source.at(ns("./title"))&.text,
        doctype: source.at(ns("./@type"))&.text,
        stage: source.at(ns("./status"))&.text,
        technical_committee: source.at(ns("./editorialgroup/technical-committee"))&.text,
        abstract: source.at(ns("./abstract"))&.text,
        revdate: revdate ? Date.parse(revdate.text) : nil,
        language: source.at(ns("./language"))&.text,
        script: source.at(ns("./script"))&.text,
        edition: source.at(ns("./edition"))&.text,
        copyright_from: source.at(ns("./copyright/from"))&.text,
        copyright_owner: source.at(ns("./copyright/owner/organization/name"))&.text,
        contributor_author_role: source.at(ns("./contributor/role[@type='author']"))&.text,
        contributor_author_organization: source.at(ns("./contributor/role[@type='author']"))&.parent&.at(ns("./organization/name"))&.text,
        contributor_publisher_role: source.at(ns("./contributor/role[@type='publisher']"))&.text,
        contributor_publisher_organization: source.at(ns("./contributor/role[@type='publisher']"))&.parent&.at(ns("./organization/name"))&.text,
        datetype: datetype
      })
    end

    def to_xml
      #datetype = stage&.casecmp("published") == 0 ? "published" : "circulated"

      ret = "<bibdata type='#{doctype}'>\n"
      ret += "<fetched>#{Date.today.to_s}</fetched>\n"
      ret += "<title>#{title}</title>\n"
      ret += "<docidentifier>#{docidentifier}</docidentifier>\n" if docidentifier
      ret += "<uri>#{uri}</uri>\n" if uri
      ret += "<uri type='xml'>#{xml}</uri>\n" if xml
      ret += "<uri type='html'>#{html}</uri>\n" if html
      ret += "<uri type='pdf'>#{pdf}</uri>\n" if pdf
      ret += "<uri type='doc'>#{doc}</uri>\n" if doc
      ret += "<uri type='rxl'>#{rxl}</uri>\n" if rxl

      ret += "<language>#{language}</language>\n"
      ret += "<script>#{script}</script>\n"

      if copyright_from
        ret += "<copyright>"
        ret += "<from>#{copyright_from}</from>\n" if copyright_from
        ret += "<owner><organization><name>#{copyright_owner}</name></organization></owner>\n" if copyright_owner
        ret += "</copyright>"
      end

      if contributor_author_role
        ret += "<contributor>\n"
        ret += "<role type='author'/>\n"
        ret += "<organization><name>#{contributor_author_organization}</name></organization>\n"
        ret += "</contributor>\n"
      end

      if contributor_publisher_role
        ret += "<contributor>\n"
        ret += "<role type='publisher'/>\n"
        ret += "<organization><name>#{contributor_publisher_organization}</name></organization>\n"
        ret += "</contributor>\n"
      end

      ret += "<date type='#{datetype}'><on>#{revdate}</on></date>\n" if revdate
      # ret += "<contributor><role type='author'/><organization><name>#{agency}</name></organization></contributor>" if agency
      # ret += "<contributor><role type='publisher'/><organization><name>#{agency}</name></organization></contributor>" if agency
      ret += "<edition>#{edition}</edition>\n" if edition
      ret += "<language>#{language}</language>\n" if language
      ret += "<script>#{script}</script>\n" if script
      ret += "<abstract>#{abstract}</abstract>\n" if abstract
      ret += "<status>#{stage}</status>\n" if stage
      ret += "<editorialgroup><technical-committee>#{technical_committee}</technical-committee></editorialgroup>\n" if technical_committee
      ret += "</bibdata>\n"
    end

    def to_h
      ATTRIBS.inject({}) do |acc, k|
        value = send(k)
        acc[k.to_s] = value unless value.nil?
        acc
      end
    end

    def to_yaml
      to_h.to_yaml
    end

  end
end
