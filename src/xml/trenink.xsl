<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes"/>

  <!-- key to lookup exercise definition by id -->
  <xsl:key name="def-by-id" match="root/exerciseDefinitions/item" use="id"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>
          <xsl:choose>
            <xsl:when test="root/unit/name">Training - <xsl:value-of select="root/unit/name"/></xsl:when>
            <xsl:otherwise>Training</xsl:otherwise>
          </xsl:choose>
        </title>
        <link rel="stylesheet" href="styles.css"/>
      </head>
      <body>
        <div class="container">
          <header>
            <h1><xsl:value-of select="root/unit/name"/></h1>
            <div class="meta">
              <strong>Client:</strong> <xsl:value-of select="root/unit/clientId"/>
              <xsl:if test="normalize-space(root/unit/note) != ''"> | <strong>Note:</strong> <xsl:value-of select="root/unit/note"/></xsl:if>
            </div>
          </header>

          <section id="definitions">
            <h2>Exercise definitions</h2>
            <xsl:for-each select="root/exerciseDefinitions/item">
              <section class="exercise">
                <h2><xsl:value-of select="name"/></h2>
                <div class="meta">
                  <strong>Category:</strong> <xsl:value-of select="category"/>
                  <xsl:if test="isDefault = 'True'">
                    <span class="badge">Default</span>
                  </xsl:if>
                </div>
                <div class="description"><p><xsl:value-of select="normalize-space(description)"/></p></div>
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
                <div class="meta"><strong>ID:</strong> <xsl:value-of select="id"/></div>
              </section>
            </xsl:for-each>
          </section>

          <section id="unit-exercises">
            <h2>Training unit (sequence)</h2>
            <ol>
              <xsl:for-each select="root/exercisesInUnit/item">
                <xsl:sort select="number(orderIndex)" data-type="number"/>
                <li>
                  <xsl:variable name="def" select="key('def-by-id', exerciseId)"/>
                  <xsl:choose>
                    <xsl:when test="$def">
                      <section class="exercise">
                        <h2><xsl:value-of select="$def/name"/></h2>
                        <div class="meta">
                          <strong>Order:</strong> <xsl:value-of select="orderIndex"/>
                          <xsl:if test="reps"> | <strong>Reps:</strong> <xsl:value-of select="reps"/></xsl:if>
                          <xsl:if test="sets"> | <strong>Sets:</strong> <xsl:value-of select="sets"/></xsl:if>
                          <xsl:if test="rest"> | <strong>Rest (s):</strong> <xsl:value-of select="rest"/></xsl:if>
                        </div>
                        <div class="description"><p><xsl:value-of select="normalize-space($def/description)"/></p></div>
                        <xsl:if test="$def/muscleGroups/item">
                          <div class="muscles">
                            <strong>Muscles:</strong>
                            <ul>
                              <xsl:for-each select="$def/muscleGroups/item">
                                <li><xsl:value-of select="normalize-space(.)"/></li>
                              </xsl:for-each>
                            </ul>
                          </div>
                        </xsl:if>
                        <div class="meta"><strong>ID:</strong> <xsl:value-of select="$def/id"/></div>
                      </section>
                    </xsl:when>
                    <xsl:otherwise>
                      <section class="exercise">
                        <h2>Unknown exercise ID: <xsl:value-of select="exerciseId"/></h2>
                      </section>
                    </xsl:otherwise>
                  </xsl:choose>
                </li>
              </xsl:for-each>
            </ol>
          </section>
        </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
