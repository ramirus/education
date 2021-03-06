class Admin::WorkshopsController < ApplicationController
  before_action { check_permission(:admin) }
  before_action :find_workshop, only: [:show, :edit, :update, :approve, :deny, :destroy]

  def index
    @sections = Section.where.not(:is_main => true)
    section_params = params[:section_id]
    if section_params
      @workshops_special =  Workshop.where.not('workshops.special_guest_id' => nil).where(section: section_params)
      @workshops_usual = Workshop.where.not('workshops.user_id' => nil).where(section: section_params)
    else
      @workshops_special =  Workshop.where.not('workshops.special_guest_id' => nil)
      @workshops_usual = Workshop.where.not('workshops.user_id' => nil)
    end
  end

  def new
    @workshop = Workshop.new
  end

  def create
    @workshop = Workshop.new(workshop_params)
    @workshop.status= Workshop.statuses[:confirmed]
    if @workshop.save
      redirect_to admin_workshops_path
    else
      render 'new'
    end
  end

  def destroy
    @workshop.destroy
    redirect_to admin_workshops_path
  end

  def show
    @comment = Comment.new
    @comments = Comment.where(:workshop => @workshop)
  end

  def edit
  end

  def update
    if @workshop.update(workshop_params)
      redirect_to admin_workshop_path
    else
      render 'edit'
    end
  end

  def approve
    @workshop.update(:status => Workshop.statuses[:confirmed])
    UserMailer.workshop_confirmed_email(@workshop).deliver_now
    redirect_to admin_workshop_path
  end

  def deny
    @workshop.update(:status => Workshop.statuses[:denied])
    UserMailer.workshop_denied_email(@workshop).deliver_now
    redirect_to admin_workshop_path
  end

  def excel
    section_params = params[:section_id]
    if section_params
      workshops = Workshop.where.not('workshops.user_id' => nil).where(section: section_params)
    else
      workshops = Workshop.where.not('workshops.user_id' => nil)
    end

    spreadsheet_name = 'Доклады'

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => spreadsheet_name
    sheet1.row(0).replace ['Тема доклада',
                           'Конференция',
                           'Статус',
                           'Докладчик',
                           'Страна',
                           'Город']

    workshops.each_with_index { |ws, i|
      sheet1.row(i+1).replace [ws.title, ws.try(:section).try(:title), t("workshop_status.#{ws.status}"), ws.user.readable_name, ws.user.country, ws.user.city]
    }

    export_file_path = [Rails.root, 'public', 'uploads', 'exports', "#{ spreadsheet_name }_#{ DateTime.now.to_s }.xls"].join("/")
    book.write export_file_path
    send_file export_file_path, :content_type => 'application/vnd.ms-excel', :disposition => 'inline'

  end

  private

  def workshop_params
    params.require(:workshop).permit(:title, :title_en, :description, :description_en, :special_guest_id, :section_id)
  end

  def find_workshop
    @workshop = Workshop.find(params[:id])
    render_404 unless @workshop
  end


end