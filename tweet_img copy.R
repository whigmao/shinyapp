library(rtweet)
library(dplyr)
library(tidyverse)

df <- read_csv("TeamPython/data/New_balance_valid_url.csv")

unique(df[,2])

df_sa_orginal <- df %>%
  filter(country_code == "SA")

screen_name <- df_sa_orginal[851:1000,4]


api_key <- "owL3x8WeEke0BCHCQHUvEykKv"
api_secret_key <- "gam4Ha8K2UOOgisXxSIU35vAnmNR0DXDm2ILtnOJsROOIOPyVY"
access_token <- "1225979021344878594-B2jw0KZO5xDddPV5Vn8sQOuOvfCzwc"
access_token_secret <- "Ir0Lg9rwBzFTZd0Zy62Lb3sE14SrrjYdIKBeqoNB5OXUt"

token <- create_token(
  app = "mylastsemester",
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

#1:100
#101:250
#251:400
#401:550
#551:700
#701:850
#851:1000

# neilfws <- get_timeline("USGS_TexasRain", n = 100)
# image_url <- neilfws %>% 
#   filter(is_retweet == F) %>% 
#   filter(!is.na(media_url)) %>% 
#   select(screen_name,media_url)
# neilfws %>%
#   glimpse()

for ( i in screen_name)
  user_information <- get_timeline(i, n = 100, token = token)
  df7 <- user_information %>% 
    filter(is_retweet == F) %>% 
    filter(!is.na(media_url)) %>% 
    select(screen_name,media_url)
  
df7['country'] <- "SA"


df_sa <- rbind(df1, df2, df3, df4, df5, df6, df7)

final_df <- rbind(df_us, df_br, df_ar, df_gb, df_mx, df_id, df_in, df_other, df_sa, df_tr, df_jp)


unique(final_df[,3])

final_df$media_url <- vapply(final_df$media_url, paste, collapse = ", ", character(1L))

write.csv(final_df,"media_url.csv", row.names = FALSE)

# df <- data.frame(b = c(1, 1, 1), c = c(2, 2, 2), d = c(3, 3, 3))
# df
# 
# df['country'] <- "US"
# df


