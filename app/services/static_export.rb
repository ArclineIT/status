# Writes the status page as two self-contained HTML files, index.html and
# history.html, with all CSS inlined. They can be served by any web server, or
# from a different host than the one whose status they report.
class StaticExport
  # fonts.css is left out: its files cannot travel inside a single HTML file,
  # so the static pages use the system font stack.
  STYLESHEETS = %w[ tokens base components sections portal ].freeze

  def initialize(directory)
    @directory = Pathname(directory)
  end

  def call
    @directory.mkpath
    page = StatusPage.new

    write "index.html", "#{page.headline} — #{page.title}", "status/page", page: page
    write "history.html", "Incident history — #{page.title}", "status/history",
          incidents: Incident.history.includes(:updates).to_a, maintenances: Maintenance.past.limit(20).to_a
    %w[ index.html history.html ].map { |name| @directory.join(name) }
  end

  private
    def write(name, title, partial, locals)
      html = ApplicationController.render(template: "status/static", layout: "static",
                                          assigns: { title: title, css: css, partial: partial, locals: locals })
      @directory.join(name).write(html)
    end

    def css
      @css ||= STYLESHEETS.map { |sheet| Rails.root.join("app/assets/stylesheets/#{sheet}.css").read }.join("\n")
    end
end
