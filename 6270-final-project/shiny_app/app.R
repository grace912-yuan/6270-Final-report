# NORS Foodborne Outbreak Dashboard
# VTPEH 6270 Final Project Shiny App
# Author: Mengzhi Yuan


library(shiny)
library(bslib)
library(tidyverse)
library(DT)
library(scales)
library(bsicons)

# ---------------------------
# Load and prepare data

nors_raw <- read_csv("NORS_20260501.csv", show_col_types = FALSE)

nors <- nors_raw %>%
  mutate(
    Year = as.integer(Year),
    Month = as.integer(Month),
    Illnesses = as.numeric(Illnesses),
    Hospitalizations = as.numeric(Hospitalizations),
    Deaths = as.numeric(Deaths),
    State = if_else(is.na(State) | State == "", "Unknown", State),
    `Primary Mode` = if_else(is.na(`Primary Mode`) | `Primary Mode` == "", "Unknown", `Primary Mode`),
    Etiology = if_else(is.na(Etiology) | Etiology == "", "Unknown", Etiology),
    Setting = if_else(is.na(Setting) | Setting == "", "Unknown", Setting),
    `Food Vehicle` = if_else(is.na(`Food Vehicle`) | `Food Vehicle` == "", "Not reported", `Food Vehicle`),
    `IFSAC Category` = if_else(is.na(`IFSAC Category`) | `IFSAC Category` == "", "Not reported", `IFSAC Category`)
  ) %>%
  filter(!is.na(Year))

year_min <- min(nors$Year, na.rm = TRUE)
year_max <- max(nors$Year, na.rm = TRUE)

state_choices <- c("All states", sort(unique(nors$State)))

outcome_choices <- c(
  "Reported outbreaks" = "outbreaks",
  "Illnesses" = "illnesses",
  "Hospitalizations" = "hospitalizations",
  "Deaths" = "deaths"
)

category_choices <- c(
  "Etiology" = "Etiology",
  "Primary Mode" = "Primary Mode",
  "Setting" = "Setting",
  "Food Vehicle" = "Food Vehicle",
  "IFSAC Category" = "IFSAC Category",
  "State" = "State"
)

metric_choices <- c(
  "Number of outbreaks" = "outbreaks",
  "Total illnesses" = "illnesses",
  "Total hospitalizations" = "hospitalizations",
  "Total deaths" = "deaths"
)

# ---------------------------
# Helper functions

filter_nors <- function(data, year_range, state_choice) {
  filtered <- data %>%
    filter(Year >= year_range[1], Year <= year_range[2])
  
  if (state_choice != "All states") {
    filtered <- filtered %>% filter(State == state_choice)
  }
  
  filtered
}

summarize_by_year <- function(data, outcome) {
  data %>%
    group_by(Year) %>%
    summarise(
      value = case_when(
        outcome == "outbreaks" ~ n(),
        outcome == "illnesses" ~ sum(Illnesses, na.rm = TRUE),
        outcome == "hospitalizations" ~ sum(Hospitalizations, na.rm = TRUE),
        outcome == "deaths" ~ sum(Deaths, na.rm = TRUE),
        TRUE ~ NA_real_
      ),
      .groups = "drop"
    )
}

make_summary_sentence <- function(data, outcome_label) {
  if (nrow(data) == 0) {
    return("No records are available for the selected filters.")
  }
  
  total_value <- sum(data$value, na.rm = TRUE)
  mean_value <- mean(data$value, na.rm = TRUE)
  median_value <- median(data$value, na.rm = TRUE)
  min_value <- min(data$value, na.rm = TRUE)
  max_value <- max(data$value, na.rm = TRUE)
  
  paste0(
    "For the selected filters, the total ", tolower(outcome_label),
    " across years is ", comma(total_value),
    ". The mean per year is ", comma(round(mean_value, 1)),
    ", the median per year is ", comma(round(median_value, 1)),
    ", and the yearly range is ", comma(min_value), " to ", comma(max_value), "."
  )
}

# ---------------------------
# UI

ui <- page_navbar(
  title = "NORS Foodborne Outbreak Dashboard",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#1F6F78",
    secondary = "#F4A261",
    base_font = font_google("Source Sans 3"),
    heading_font = font_google("Source Sans 3")
  ),
  
  nav_panel(
    "Overview",
    layout_columns(
      col_widths = c(5, 7),
      
      card(
        card_header("About this app"),
        p(
          "This dashboard explores outbreak patterns using data from the National Outbreak Reporting System (NORS). ",
          "The app is designed to complement the final project report by allowing users to interactively examine outbreak burden, severity, ",
          "and common outbreak characteristics across years and locations."
        ),
        p(
          strong("Motivating question: "),
          "How do reported outbreaks, illnesses, hospitalizations, and deaths vary across time, states, and outbreak characteristics?"
        ),
        p(
          strong("How to use it: "),
          "Use the Trend Explorer and Outbreak Profile tabs to filter the data and update the visual summaries."
        )
      ),
      
      layout_columns(
        col_widths = c(6, 6),
        value_box(
          title = "Total outbreaks",
          value = textOutput("total_outbreaks"),
          showcase = bsicons::bs_icon("bar-chart")
        ),
        value_box(
          title = "Total illnesses",
          value = textOutput("total_illnesses"),
          showcase = bsicons::bs_icon("people")
        ),
        value_box(
          title = "Hospitalizations",
          value = textOutput("total_hospitalizations"),
          showcase = bsicons::bs_icon("hospital")
        ),
        value_box(
          title = "Deaths",
          value = textOutput("total_deaths"),
          showcase = bsicons::bs_icon("exclamation-triangle")
        )
      )
    ),
    
    card(
      card_header("Overall trend in reported outbreaks"),
      plotOutput("overview_trend", height = "420px")
    ),
    
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Top 10 reported states"),
        plotOutput("top_states", height = "360px")
      ),
      card(
        card_header("Top 10 reported etiologies"),
        plotOutput("top_etiologies", height = "360px")
      )
    )
  ),
  
  nav_panel(
    "Trend Explorer",
    layout_sidebar(
      sidebar = sidebar(
        h4("Choose filters"),
        sliderInput(
          inputId = "trend_years",
          label = "Year range",
          min = year_min,
          max = year_max,
          value = c(year_min, year_max),
          sep = ""
        ),
        selectInput(
          inputId = "trend_state",
          label = "State",
          choices = state_choices,
          selected = "All states"
        ),
        radioButtons(
          inputId = "trend_outcome",
          label = "Outcome to visualize",
          choices = outcome_choices,
          selected = "outbreaks"
        ),
        actionButton(
          inputId = "update_trend",
          label = "Update trend",
          class = "btn-primary"
        ),
        hr(),
        p("Click the button after changing filters to update the figure and summary.")
      ),
      
      card(
        card_header("Yearly trend based on selected filters"),
        plotOutput("trend_plot", height = "460px")
      ),
      
      card(
        card_header("Summary statistics"),
        textOutput("trend_summary")
      )
    )
  ),
  
  nav_panel(
    "Outbreak Profile",
    layout_sidebar(
      sidebar = sidebar(
        h4("Choose profile options"),
        sliderInput(
          inputId = "profile_years",
          label = "Year range",
          min = year_min,
          max = year_max,
          value = c(year_min, year_max),
          sep = ""
        ),
        selectInput(
          inputId = "profile_category",
          label = "Category to rank",
          choices = category_choices,
          selected = "Etiology"
        ),
        selectInput(
          inputId = "profile_metric",
          label = "Metric",
          choices = metric_choices,
          selected = "outbreaks"
        ),
        sliderInput(
          inputId = "profile_top_n",
          label = "Number of categories to show",
          min = 5,
          max = 20,
          value = 10,
          step = 5
        ),
        actionButton(
          inputId = "update_profile",
          label = "Update profile",
          class = "btn-primary"
        ),
        hr(),
        p("This tab ranks selected outbreak characteristics using the chosen metric.")
      ),
      
      card(
        card_header("Ranked outbreak profile"),
        plotOutput("profile_plot", height = "520px")
      ),
      
      card(
        card_header("Interpretation"),
        textOutput("profile_summary")
      )
    )
  ),
  
  nav_panel(
    "Data & Methods",
    layout_columns(
      col_widths = c(6, 6),
      
      card(
        card_header("Data source and methods"),
        p(
          strong("Data source: "),
          "National Outbreak Reporting System (NORS) dataset used for the VTPEH 6270 final project."
        ),
        p(
          strong("Methods: "),
          "The app summarizes outbreak records using counts and totals. Yearly trends are shown using aggregated annual values. ",
          "Ranked profiles are based on either the number of outbreak records or total reported illnesses, hospitalizations, or deaths."
        ),
        p(
          strong("Important note: "),
          "Missing values are retained in the dataset where appropriate. For numeric summaries, missing values are excluded from totals."
        )
      ),
      
      card(
        card_header("Project information"),
        p(strong("Author: "), "Mengzhi Yuan"),
        p(strong("Course: "), "VTPEH 6270"),
        p(
          strong("GitHub repository: "),
          a(
            "https://github.com/grace912-yuan/6270-Final-report",
            href = "https://github.com/grace912-yuan/6270-Final-report",
            target = "_blank",
            rel = "noopener noreferrer"
          )
        )
        ),
        p(
          strong("AI disclosure: "),
          "ChatGPT was used to assist with code debugging, app organization. ",
          "All final decisions, analyses, and interpretations were reviewed and edited by the author."
        )
      )
    ),
    
    card(
      card_header("Preview of the dataset"),
      DTOutput("data_table")
    )
  )


# ---------------------------
# Server

server <- function(input, output, session) {
  
  # Overview value boxes
  output$total_outbreaks <- renderText({
    comma(nrow(nors))
  })
  
  output$total_illnesses <- renderText({
    comma(sum(nors$Illnesses, na.rm = TRUE))
  })
  
  output$total_hospitalizations <- renderText({
    comma(sum(nors$Hospitalizations, na.rm = TRUE))
  })
  
  output$total_deaths <- renderText({
    comma(sum(nors$Deaths, na.rm = TRUE))
  })
  
  # Overview plots
  output$overview_trend <- renderPlot({
    plot_data <- nors %>%
      count(Year, name = "outbreaks")
    
    ggplot(plot_data, aes(x = Year, y = outbreaks)) +
      geom_line(linewidth = 0.8) +
      geom_point(size = 1.8) +
      labs(
        title = "Reported outbreak records by year",
        subtitle = "Each point represents the number of outbreak records reported in that year",
        x = "Year",
        y = "Number of reported outbreaks"
      ) +
      scale_y_continuous(labels = comma) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank()
      )
  })
  
  output$top_states <- renderPlot({
    plot_data <- nors %>%
      count(State, sort = TRUE, name = "outbreaks") %>%
      slice_head(n = 10) %>%
      mutate(State = fct_reorder(State, outbreaks))
    
    ggplot(plot_data, aes(x = State, y = outbreaks)) +
      geom_col() +
      coord_flip() +
      labs(
        title = "Top 10 states by reported outbreak records",
        x = NULL,
        y = "Number of reported outbreaks"
      ) +
      scale_y_continuous(labels = comma) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank()
      )
  })
  
  output$top_etiologies <- renderPlot({
    plot_data <- nors %>%
      filter(Etiology != "Unknown") %>%
      count(Etiology, sort = TRUE, name = "outbreaks") %>%
      slice_head(n = 10) %>%
      mutate(Etiology = fct_reorder(Etiology, outbreaks))
    
    ggplot(plot_data, aes(x = Etiology, y = outbreaks)) +
      geom_col() +
      coord_flip() +
      labs(
        title = "Top 10 reported etiologies",
        x = NULL,
        y = "Number of reported outbreaks"
      ) +
      scale_y_continuous(labels = comma) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank()
      )
  })
  
  # Trend Explorer
  trend_data <- eventReactive(input$update_trend, {
    filtered <- filter_nors(nors, input$trend_years, input$trend_state)
    summarize_by_year(filtered, input$trend_outcome)
  }, ignoreInit = FALSE)
  
  output$trend_plot <- renderPlot({
    plot_data <- trend_data()
    
    validate(
      need(nrow(plot_data) > 0, "No data are available for the selected filters.")
    )
    
    selected_label <- names(outcome_choices)[outcome_choices == input$trend_outcome]
    
    ggplot(plot_data, aes(x = Year, y = value)) +
      geom_line(linewidth = 0.9) +
      geom_point(size = 2.2) +
      labs(
        title = paste("Yearly trend in", tolower(selected_label)),
        subtitle = paste(
          "State:",
          input$trend_state,
          "| Years:",
          input$trend_years[1],
          "to",
          input$trend_years[2]
        ),
        x = "Year",
        y = selected_label
      ) +
      scale_y_continuous(labels = comma) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank()
      )
  })
  
  output$trend_summary <- renderText({
    plot_data <- trend_data()
    selected_label <- names(outcome_choices)[outcome_choices == input$trend_outcome]
    make_summary_sentence(plot_data, selected_label)
  })
  
  # Outbreak Profile
  profile_data <- eventReactive(input$update_profile, {
    filtered <- nors %>%
      filter(Year >= input$profile_years[1], Year <= input$profile_years[2])
    
    category_var <- input$profile_category
    metric <- input$profile_metric
    
    filtered %>%
      filter(!is.na(.data[[category_var]]), .data[[category_var]] != "Unknown") %>%
      group_by(category = .data[[category_var]]) %>%
      summarise(
        value = case_when(
          metric == "outbreaks" ~ n(),
          metric == "illnesses" ~ sum(Illnesses, na.rm = TRUE),
          metric == "hospitalizations" ~ sum(Hospitalizations, na.rm = TRUE),
          metric == "deaths" ~ sum(Deaths, na.rm = TRUE),
          TRUE ~ NA_real_
        ),
        .groups = "drop"
      ) %>%
      arrange(desc(value)) %>%
      slice_head(n = input$profile_top_n) %>%
      mutate(category = fct_reorder(category, value))
  }, ignoreInit = FALSE)
  
  output$profile_plot <- renderPlot({
    plot_data <- profile_data()
    
    validate(
      need(nrow(plot_data) > 0, "No data are available for the selected options.")
    )
    
    metric_label <- names(metric_choices)[metric_choices == input$profile_metric]
    
    ggplot(plot_data, aes(x = category, y = value)) +
      geom_col() +
      coord_flip() +
      labs(
        title = paste("Top", input$profile_top_n, input$profile_category, "categories"),
        subtitle = paste(
          "Ranked by",
          tolower(metric_label),
          "from",
          input$profile_years[1],
          "to",
          input$profile_years[2]
        ),
        x = NULL,
        y = metric_label
      ) +
      scale_y_continuous(labels = comma) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank()
      )
  })
  
  output$profile_summary <- renderText({
    plot_data <- profile_data()
    
    if (nrow(plot_data) == 0) {
      return("No records are available for the selected profile options.")
    }
    
    metric_label <- names(metric_choices)[metric_choices == input$profile_metric]
    top_category <- as.character(plot_data$category[which.max(plot_data$value)])
    top_value <- max(plot_data$value, na.rm = TRUE)
    
    paste0(
      "For the selected years, the highest-ranked category is ",
      top_category,
      " with ",
      comma(top_value),
      " ",
      tolower(metric_label),
      ". This ranking helps identify which outbreak characteristics contribute most to the selected burden measure."
    )
  })
  
  # Data table
  output$data_table <- renderDT({
    nors %>%
      select(
        Year,
        Month,
        State,
        `Primary Mode`,
        Etiology,
        `Etiology Status`,
        Setting,
        Illnesses,
        Hospitalizations,
        Deaths,
        `Food Vehicle`,
        `IFSAC Category`
      ) %>%
      datatable(
        options = list(
          pageLength = 10,
          scrollX = TRUE
        ),
        rownames = FALSE
      )
  })
}

# ---------------------------
# Run app
# ---------------------------

shinyApp(ui = ui, server = server)
