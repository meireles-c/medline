class AppointmentsController < ApplicationController
  before_action :authenticate_user!, except: :index

  def new
    @appointment = Appointment.new
    @specialties = []
    @specialty = ""
    @doctors = []
    if params[:appointment].present? && params[:appointment][:clinic].present?
      @appointment.clinic = Clinic.find(params[:appointment][:clinic])
      @specialties = @appointment.clinic.doctors.distinct.pluck(:specialty)
    end
    if params[:appointment].present? && params[:appointment][:specialty].present?
      @specialty = params[:appointment][:specialty]
      @doctors = Doctor.where(clinic: @appointment.clinic, specialty: @specialty)
    end
    if params[:appointment].present? && params[:appointment][:doctor].present?
      @appointment.doctor = Doctor.find(params[:appointment][:doctor])
    end
  end

  def emergency
    @appointment = Appointment.new
    @appointment.user = current_user
    @appointment.emergency = true
    @appointment.clinic = Clinic.find(params[:clinic_id])
    estimated_time = params[:estimated_time]
    @appointment.time = Time.current.advance(minutes: estimated_time.to_i)
    if @appointment.save
      flash[:notice] = "Emergencia registrada com sucesso"
      redirect_to my_appointments_appointments_path
    end
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.user = current_user
    @doctor = Doctor.find(params[:appointment][:doctor])
    @clinic = @doctor.clinic
    @appointment.doctor = @doctor
    @appointment.clinic = @clinic
    date_time = "#{params[:appointment][:time]} #{params[:appointment]['created_at(4i)']}:#{params[:appointment]['created_at(5i)']} -03"
    date = DateTime.strptime(date_time, '%d-%m-%y %H:%M %z')
    @appointment.time = date
    if @appointment.save
      redirect_to my_appointments_appointments_path
    else
      render "new", status: :unprocessable_entity
    end
  end


  def index
    @appointments = Appointment.all
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    if @appointment.user == current_user
      @appointment.destroy
      redirect_to my_appointments_appointments_path
    end
  end


  def history
    @appointments = Appointment.history(current_user)
  end

  def my_appointments
    @appointments = Appointment.upcoming(current_user)
  end



  private

  def appointment_params
    params.require(:appointment).permit(:time, :status, :emergency, :date_position, :screening)
  end

end
