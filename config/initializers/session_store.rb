Rails.application.config.session_store :cookie_store, {
  key: "user_id",
  domain: :all,
  expire_after: 12.hours,
}