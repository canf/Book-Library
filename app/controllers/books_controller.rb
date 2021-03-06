# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy library]
  before_action :authenticate_user!, except: %i[index show]

  # GET /books
  # GET /books.json
  def index
    @books = if params[:tag]
               Book.tagged_with(params[:tag])
             else
               Book.all
             end
  end

  # GET /books/1
  # GET /books/1.json
  def show
    # @book = Book.find(params[:id])
    @com = Com.new
    @com.book_id = @book.id
  end

  # GET /books/new
  def new
    @book = current_user.books.build
  end

  # GET /books/1/edit
  def edit; end

  # POST /books
  # POST /books.json
  def create
    @book = current_user.books.build(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def as_json(options = {})
    super(options.merge(include: [:user, comments: { include: :user }]))
  end

  # add and remove books from/to library
  def library
    type = params[:type]

    if type == 'add'
      current_user.library_additions << @book
      redirect_to library_index_path, notice: "#{@book.title} was added to your library"
    elsif type == 'remove'
      current_user.library_additions.delete(@book)
      redirect_to root_path, notice: "#{@book.title} was removed from your library"
    else
      # type is missing, nothing happens
      redirect_to book_path(@book), notice: 'Looks like nothing happend'
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def book_params
    params.require(:book).permit(:title, :description, :author, :user_id, :image, :tag_list)
  end

  def com_params
    params.require(:com).permit(:body, :user_id)
  end
end
