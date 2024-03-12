defmodule TaskManagementWeb.Router do
  use TaskManagementWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskManagementWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug TaskManagementWeb.Plugs.Auth.UserPipeline
  end

  scope "/", TaskManagementWeb do
    pipe_through :browser
    live "/", HomeLive
  end

  scope "/api", TaskManagementWeb do
    pipe_through :api

    post "/user", UsersController, :create
    post "/user/login", UsersController, :login
  end

  scope "/api", TaskManagementWeb do
    pipe_through [:api, :authenticated]

    delete "/user/logout", UsersController, :logout

    delete "/user", UsersController, :delete
    get "/user", UsersController, :show
    patch "/user", UsersController, :update

    resources "/boards", BoardsController, only: [:create, :show, :delete, :update]

    post "/boards/members", BoardsController, :add_member
    delete "/boards/members/:board_id/:member_id", BoardsController, :remove_member
    patch "/boards/members/:board_id/:member_id", BoardsController, :update_member

    resources "/boards/tasks", TasksController, only: [:create, :delete, :show, :update]
    patch "/boards/tasks/add-member/:task_id/:member_id", TasksController, :add_member

    patch(
      "/boards/tasks/remove-member/:task_id/:member_id",
      TasksController,
      :remove_member
    )
  end
end
