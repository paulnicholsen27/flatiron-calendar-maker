class MainController < ApplicationController
  def homepage

  end

  def create_calendar

    flash.notice = "Calendar created successfully"
    redirect_to homepage_path
  end

  private

  def get_lecture_schedule

  end
end
