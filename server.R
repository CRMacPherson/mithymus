shinyServer(function(input, output, session) {
  ########### > REACTIVE VALUES ----
  ###########
  rv = shiny::reactiveValues()
  rv$test = data.frame(Age = numeric(), Sex = character(), Genotype = character())
  rv$simple = data.frame(Age = numeric(), Sex = character(), Genotype = character(), sjTREC = numeric())
  
  ########### > SHOW REVIEW MODAL
  ###########
  #observeEvent(TRUE,{
  #  shiny::showModal(shiny::modalDialog(title = "REVIEWER EDITION: IMPORTANT NOTICE", size = 'm', easyClose = TRUE,
  #                                      shiny::tags$p("This companion app is a review edition and does not reflect the content of the final version."),
  #                                      shiny::tags$p("All comments are welcome, please refer to the `Shiny app` when doing so during the review process."),
  #                                      shiny::tags$p("The help section contains an interactive slide deck explaining all features found in this app."),
  #                                      shiny::tags$p("Thank you for your time,"),
  #                                      shiny::tags$p("Milieu Interieur Consortium")
  #  ))
  #})
  
  ########### > MODEL DATA ----
  ###########
  getData = shiny::reactive({
    data = read.csv("./data/TRECpred.17022017.csv", sep=",", header=TRUE, stringsAsFactors = TRUE)
    #data$sjTREC[is.na(data$sjTREC)] <- 2.4
    data = data[!is.na(data$sjTREC),]
    return (data)
  })
  
  getModel = shiny::reactive({
    data = getData()
    model = lm(data=data, sjTREC ~ rs_TREC + SEX + AGE.V0)
    return (model)
  })
  
  getSimplePrediction = function(age, sex, genotype) {
    model = getModel()
    sex = switch(sex, "Female" = "Women", "Male" = "Men")
    new = data.frame(AGE.V0 = age, SEX = sex, rs_TREC = genotype)
    return (predict(model, type = "response", newdata = new))
  }
  ########### > USER DATA (NEW DATA) ----
  ###########
  ###>> SIMPLE QUERY INPUT (button listener) ----
  shiny::observeEvent(input$simple_prediction_predict_button, {
    #- Fetch data
    age = shiny::isolate(input$simple_prediction_age_slider)
    sex = shiny::isolate(input$simple_prediction_sex_radio)
    genotype =  shiny::isolate(input$simple_prediction_genotype_selector)
    #- Predict sjTREC
    trec = getSimplePrediction(age, sex, genotype)
    #- Add data
    rv$simple = rbind(rv$simple, data.frame(Age = age, Gender = sex, Genotype = genotype, sjTREC = trec))
  })
  ###>> SIMPLE QUERY RESULT (data listener) ----
  output$simple_prediction_result_text = shiny::renderText({
    if (dim(rv$simple)[1] == 0) {return ("Click \"Go\" to make your first prediction.")}
    last_prediction = rv$simple$sjTREC[dim(rv$simple)[1]]
    return (paste("Predicted result is ",last_prediction, sep=""))
  })
  ###>> SIMPLE QUERY PLOT PAST RESULTS (data listener) ----
  output$simple_prediction_result_plot = plotly::renderPlotly({
    height = input$plot_height
    if (dim(rv$simple)[1] == 0) {
      ax = list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE, range = c(0,2))
      custom_text = list(x = 1, y = 1, text = "No data to show! Please use the controls on the left.", xref = "x", yref = "y")
      return (plotly::plot_ly() %>% #plotly::add_markers() %>%
              plotly::layout(xaxis = ax, yaxis = ax, annotations = custom_text) %>% 
              plotly::config(displayModeBar = FALSE))
    }
    original.data = getData()
    colnames(original.data) = c("sjTREC","Age","Gender","Genotype")
    layered.plot = original.data %>% ggplot2::ggplot(aes(x = Age, y = sjTREC))
    if ("Plot background data" %in% input$chkboxgrp_plot) {layered.plot = layered.plot + ggplot2::geom_hex(bins = 15) + ggplot2::scale_fill_continuous(low = c("#EBEFFF"), high = c("#9494FF"), guide = FALSE)}
    if ("Plot history" %in% input$chkboxgrp_plot) {
      if ("Group by gender" %in% input$chkboxgrp_plot) {
        if ("Group by genotype" %in% input$chkboxgrp_plot) {layered.plot = layered.plot + ggplot2::geom_point(data = rv$simple, size = 4, mapping = ggplot2::aes(color = Gender, shape = Genotype))}
        else {layered.plot = layered.plot + ggplot2::geom_point(data = rv$simple, size = 4, shape = 16, mapping = ggplot2::aes(color = Gender))}
      }
      else if ("Group by genotype" %in% input$chkboxgrp_plot) {layered.plot = layered.plot + ggplot2::geom_point(data = rv$simple, size = 4, mapping = ggplot2::aes(shape = Genotype))}
      else {layered.plot = layered.plot + ggplot2::geom_point(data = rv$simple, fill = "orange", size = 4, shape = 21)}
      layered.plot = layered.plot +
        ggplot2::scale_shape_discrete(name = "", breaks = c("Female", "Male"), labels = c("Female", "Male")) +
        ggplot2::scale_color_discrete(name = "", breaks = c("Female", "Male"), labels = c("Female", "Male"))
      layered.plot = layered.plot + ggplot2::geom_point(data = rv$simple[dim(rv$simple)[1],], size = 2, shape = 16, color = "black")
    }
    else {
      layered.plot = layered.plot + ggplot2::geom_point(data = rv$simple[dim(rv$simple)[1],], color = "black", fill = "orange", size = 6, shape = 21)
    }
    layered.plot = layered.plot + theme(axis.line = element_line(linetype = "solid"), axis.ticks = element_line(colour = "gray0", 
        size = 2), panel.grid.major = element_line(colour = "black"), 
        panel.grid.minor = element_line(colour = "gray87"),
        panel.background = element_rect(fill = "white"))
    plotly::ggplotly(layered.plot) %>% plotly::layout(yaxis=list(title="Log10(sjTREC/150 000 cells)")) %>% plotly::config(displayModeBar = FALSE)
  })
  output$simple_prediction_result_past = plotly::renderPlotly({
    if (dim(rv$simple)[1] == 0) {return (plotly::plot_ly())}
    rv$simple %>% ggplot2::ggplot(aes(x = Age, y = sjTREC, group = interaction(Sex, Genotype), color = interaction(Sex, Genotype))) + ggplot2::geom_line() + ggplot2::geom_point() + ggplot2::theme(legend.title = ggplot2::element_blank())
    plotly::ggplotly(height = input$plot_height) %>% plotly::config(displayModeBar = FALSE)
  })
  ###>> ADD SINGLE DATA POINT (button listener) ----
  shiny::observeEvent(input$add_data_button, {
    #- Fetch data
    age = shiny::isolate(input$add_age_slider)
    sex = shiny::isolate(input$add_sex_radio)
    genotype =  shiny::isolate(input$add_genotype_radio)
    if (genotype == "Unknown") {
      genotype = switch(shiny::isolate(input$add_unkownGenotype_radio),
                        "minimize sjTREC (GG)"      = "GG",
                        "maximise sjTREC (AA)"      = "AA",
                        "take middle position (GA)" = "GA",
                        "randomize (??)"            = sample(c("AA","GG","GA"), 1))
    }
    #- Update data table
    rv$test = rbind(rv$test, data.frame(Age = age, Sex = sex, Genotype = genotype))
    #- Update input widgets if `next is random` is set
    if (shiny::isolate(input$add_data_next_is_random_checkbox)) {
      shiny::updateSliderInput(session, "add_age_slider", value = runif(1, 0, 120))
      shiny::updateRadioButtons(session, "add_sex_radio", selected = sample(c("Female", "Male"),1))
      shiny::updateRadioButtons(session, "add_genotype_radio", selected = sample(c("AA", "GG", "GA"),1))
    }
  })
  ###>> CUSTOM PLOT
  output$custom_plot = shiny::renderUI({
    plotly::plotlyOutput("simple_prediction_result_plot", height = input$plot_height)
  })
  ###>> DOWNLOAD HANDLER
  output$download_link <- downloadHandler(
    "milieu_interieur.sjTREC.predictions.tsv",
    content = function(file) {
      write.table(rv$simple, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )
  ###>> PREVIEW DOWNLOAD
  shiny::observeEvent(input$preview_link, {
    shiny::showModal(shiny::modalDialog(
      title = "Preview of predictions to be downloaded",
      DT::dataTableOutput('preview'),
      easyClose = TRUE
    ))
  output$preview = DT::renderDataTable({rv$simple})
  })
  ###> ADD 10 RANDOM DATAPOINTS
  shiny::observeEvent(input$random_10, {
    #- sample
    new.data.frame = data.frame()
    #- predict sjTRECs
    for (i in 1:10) {
      age = sample(20:70, 1, replace = TRUE)
      gender = sample(c("Male", "Female"), 1, replace = TRUE)
      genotype = sample(c("GG", "GA", "AA"), 1, replace = TRUE)
      trec = getSimplePrediction(age,gender,genotype)
      new.data.frame = rbind(new.data.frame, data.frame(Age = age, Gender = gender, Genotype = genotype, sjTREC = trec))
    }
    #- update reactive data structure
    rv$simple = rbind(rv$simple, new.data.frame)
  })
})