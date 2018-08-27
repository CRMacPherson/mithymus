########### > HEADER ----
###########
shinydashboard_header = dashboardHeader(title = shiny::p(tags$a(href='http://www.milieuinterieur.fr/en',
                                                                tags$img(src='./images/mi_logo.png', height="50", style="display: block; margin-left: auto; margin-right: auto;")), "Milieu Interieur"))

########### > SIDEBAR ----
###########
shinydashboard_sidebar = dashboardSidebar(sidebarMenu(
  menuItem("Home"                  , tabName = "tab_home"      , icon = icon("home"           ), selected = TRUE),
  menuItem("Help"                  , tabName = "tab_help"      , icon = icon("question-circle")),
  menuItem("Cite"                  , tabName = "tab_about"     , icon = icon("info-circle"    ))
  )
)

########### > BODY ----
###########
tab.home     = tabItem(tabName = "tab_home"    ,
  shiny::h1("Milieu Interieur sjTREC Prediction Service", align="center"),
  shiny::tags$p("Welcome! This work is brought to you by the Milieu Interieur Consortium and is published by Clave et al., 2018.", align="center"),
  shiny::conditionalPanel('input.simple_prediction_get_started == 0',
    shiny::fluidRow(
      shiny::column(width = 1),
      shiny::column(width = 10,
                    shiny::actionButton('simple_prediction_get_started', "Click here to start with our \nSimple Prediction Service", width = "100%", style='padding:10px; font-size:150%'),
                    shiny::wellPanel(shiny::img(src = "./images/TREC.FrontFigure.png", width = "100%"))
                    ),
      shiny::column(width = 1)
    )
  ),
  shiny::conditionalPanel('input.simple_prediction_get_started', shiny::wellPanel(
    #shiny::div(align = "center", shiny::h3("Simple Prediction Service")),
    shiny::fluidRow(
      shiny::column(width=5,
        shiny::fluidRow(
          shiny::column(width = 7, 
            shiny::div(align = "center", shiny::h3("Guide")),
            shiny::tags$p("The Simple Prediction Service (SPS) is designed to give quick access to study results and outcomes. Use the basic controls on the right to predict sjTREC levels based on an individual's age, gender, and genotype. If you get stuck, please refer to the help section on the left. Full citation and author details may be found in the about section.")
          ),
          shiny::column(width = 5,
            shiny::div(align = "center", shiny::h3("Parameters")),
            shiny::sliderInput("simple_prediction_age_slider", "Age", 20, 70, value = 30),
            shiny::fluidRow(
              shiny::column(width = 6, shiny::div(align = "left", shiny::selectInput("simple_prediction_genotype_selector", "Genotype", choices = c("GG", "AA", "GA")))),
              shiny::column(width = 6, shiny::div(align = "left", shiny::radioButtons("simple_prediction_sex_radio", "Gender", choices = c("Female", "Male"), inline = FALSE)))
            ),
            shiny::actionButton("simple_prediction_predict_button", "Predict sjTREC levels", width = "100%"),
            shiny::sliderInput("plot_height", "Plot height", min = 220, max = 1000, value = 425)
          )
        ),
        shiny::img(src = "./images/TREC.FrontFigure.png", width = "100%", style="display: block; margin-left: auto; margin-right: auto;")
      ),
      shiny::column(width = 7,
        shiny::div(align = "center", shiny::h3("Prediction")),
        shiny::div(align = "center", shiny::helpText("Predicted sjTREC levels (points) in relation to background data (hex). Use mouse to interact.")),
        shiny::div(align = "center", shiny::uiOutput('custom_plot')),
        shiny::div(align = "center", 
          shiny::checkboxGroupInput('chkboxgrp_plot', NULL, choices = c("Plot background data", "Plot history", "Group by gender", "Group by genotype"), inline = TRUE),
          shiny::downloadLink('download_link', "DOWNLOAD"),
          " | ", shiny::actionLink('preview_link', "PREVIEW"),
          " | ", shiny::actionLink('random_10', "ADD 10 RANDOM")
        )
      )
    )
  ))
)

########### >> TAB: ABOUT ----
###########
tab.about = tabItem(tabName = "tab_about"   ,
#shiny::helpText("This page will contain information on all authors, the abstract of the paper, links to other MI assets, and the full citation.")
shiny::h3("Human thymopoiesis is influenced by a common genetic variant within the TCRA-TCRD locus."),
shiny::h4("Emmanuel Clave, Itaua Leston Araujo, Cecile Alanio, Etienne Patin,Jacob Bergstedt, Alejandra Urrutia, Silvia Lopez-Lastra, Yan Li, Bruno Charbit, Cameron Ross MacPherson, Milena Hasan, Breno Luiz Melo-Lima, Corinne Douay, Noemie Saut, Marine Germain, David-Alexandre Tregouet, Pierre-Emmanuel Morange, Magnus Fontes, Darragh Duffy, James P. Di Santo, Lluis Quintana-Murci, Matthew L. Albert, Antoine Toubert, The Milieu Interieur Consortium."),
shiny::h4("Sci. Transl. Med. 10, eaao2966 (2018).")
)

########### >> TAB: HELP ADD ----
###########
tab.help = tabItem(tabName = "tab_help"    ,
  shiny::h3("Help"),
  shiny::p("The following Prezi tutorial will guide you through the use of the app."),
  shiny::p("If you would prefer static help, please refer to the documentation after the tutorial. For any other queries, please email darragh<dot>duffy<at>pasteur<dot>fr."),
  
  shiny::tags$iframe(id="iframe_container", frameborder="0", webkitallowfullscreen="", mozallowfullscreen="", allowfullscreen="", width="1200", height="600", src="https://prezi.com/embed/qqyykar5efl7/?bgcolor=ffffff&amp;lock_to_path=1&amp;autoplay=0&amp;autohide_ctrls=0&amp;landing_data=bHVZZmNaNDBIWnNjdEVENDRhZDFNZGNIUE43MHdLNWpsdFJLb2ZHanI0NUVVeWZrU2VqaGJBOHFtNEJ0dDhNNS9nPT0&amp;landing_sign=cD6n7-11_vAerlKG1M9SxYYXtur2V3x4R8THUOYKYoE")
)

########### >> AGGREGATE TABS ----
###########
shinydashboard_body = dashboardBody(tabItems(
  tab.home,
  tab.about,
  tab.help
))

########### > GENERATE HTML ----
###########
dashboardPage(shinydashboard_header,
              shinydashboard_sidebar,
              shinydashboard_body,
              skin = "blue")
