class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :check_authorization, :except => [ :show ]

  
  # GET /articles
  # GET /articles.xml
  def index
    @articles = Article.paginate( :page => params[:page], :per_page => 5, :order => "created_at DESC" )
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    article       = Article.find(params[:id]) rescue nil
    username      = article.present? ? article.user.username  : 'no_user'
    article_name  = article.present? ? article.name           : 'no_article'
    
    head :moved_permanently, :location => show_article_path( username, article_name)  
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new
    @article.photos.build
    @article.documents.build
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article    = Article.find(params[:id]) if current_user.admin?
    @article  ||= current_user.articles.find(params[:id])
    
    @article.photos.build
    @article.documents.build
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = current_user.articles.build(params[:article])

    respond_to do |format|
      if @article.save
        flash[:success] = 'Article was successfully created.'
        format.html { redirect_to :action => :index }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to edit_article_path( @article ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
    end
  end
end
