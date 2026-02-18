<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>Cvičení</title>
        <link rel="stylesheet" href="styles.css"/>
      </head>
      <body>
        <div class="container">
          <header>
            <h1>Cvičení</h1>
            <p>Generováno XSLT z XML se seznamem cvičení.</p>
          </header>
          <xsl:apply-templates select="root/item"/>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="item">
    <section class="exercise">
      <h2><xsl:value-of select="name"/></h2>
      <div class="meta">
        <strong>Kategorie:</strong> <xsl:value-of select="category"/>
        <xsl:if test="isDefault = 'True'">
          <span class="badge">Default</span>
        </xsl:if>
      </div>
      <div class="description">
        <p><xsl:value-of select="normalize-space(description)"/></p>
      </div>

      <xsl:if test="mediaUrl and string-length(normalize-space(mediaUrl)) &gt; 0">
        <div class="media">
          <img class="media" src="{mediaUrl}" alt="{name}"/>
        </div>
      </xsl:if>

      <xsl:if test="muscleGroups/item">
        <div class="muscles">
          <strong>Zapojené svaly:</strong>
          <ul>
            <xsl:for-each select="muscleGroups/item">
              <li><xsl:value-of select="normalize-space(.)"/></li>
            </xsl:for-each>
          </ul>
        </div>
      </xsl:if>

      <div class="meta">
        <strong>ID:</strong> <xsl:value-of select="id"/>
      </div>
    </section>
  </xsl:template>

</xsl:stylesheet>
