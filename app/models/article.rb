class Article < ActiveRecord::Base
  include GenerateUrlName
  
  belongs_to  :user,      :counter_cache => true
  has_many    :uploads,   :as => :uploadable
  has_many    :photos,    :as => :uploadable, :dependent => :destroy
  has_many    :documents, :as => :uploadable, :dependent => :destroy
  has_many    :comments,  :as => :commentable
  has_many    :snippets,  :as => :snippetable
  
  validates_uniqueness_of :title
  validates_presence_of   :title, :body, :crest
  
  before_create :create_name
  before_update :create_name
  
  accepts_nested_attributes_for :photos,    :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :documents, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true
  
  named_scope :blogs,   :conditions => { :is_post   => true }
  named_scope :news,    :conditions => { :is_news   => true }
  named_scope :reviews, :conditions => { :is_review => true }
  
  named_scope :latest, lambda { |limit| { :limit => limit, :order => "created_at DESC" } }
end
