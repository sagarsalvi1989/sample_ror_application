require 'json'
class Api::V1Controller < ApplicationController

  def clauses
    puts '############'
    case request.method_symbol
      when :get
        if params[:id]
          begin
            @clauses = Clause.where(is_delete: false).find(params[:id])
            render :json => @clauses
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
            render :json => {'error' => 'Clause not found'}
          end
        elsif
          @clauses = Clause.where(is_delete: false)
          render :json => @clauses.order(id: :desc)
        end
      when :get
        @clauses = Clause.where(is_delete: false)
        render :json => @clauses.order(id: :desc)
      when :post
        data = JSON.parse(request.body.read)
        #
        is_clause = false
        is_title = false
        error = {}
        error_description = ''
        error_title = ''
        if data['clause_text'].to_s.empty?
          is_clause = true
        end

        if is_clause
          error_description = 'Invalid Description'
        end

        if data['title'].to_s.empty?
          is_title = true
        end

        if is_title
          error_title = 'Invalid title'
        end
        #

        if is_clause or is_title
          error['error'] = error_description + '\n' + error_title
          render :json => error
        else
          @clauses = Clause.new(:tag => data['tag'],
                                :clause_text => data['clause_text'],
                                :title => data['title'],
                                :is_delete => false)

          @clauses.save
          if @clauses.save
            render :json => @clauses
          else
            @clauses = Clause.all
            render :json => @clauses
          end
        end
      when :put
        begin
          data = JSON.parse(request.body.read)
          @clauses = Clause.where(is_delete: false).find(data['id'])

          if data.has_key?("clause_text")
            @clauses.update_column(:clause_text, data['clause_text'] )
          end

          if data.has_key?('title')
            @clauses.update_column(:title, data['title'])
          end

          if data.has_key?("tag")
            @clauses.update_column(:clause_text, data['tag'] )
          end

          render :json => @clauses
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
          render :json => {'error' => 'Clause not found'}
        end
      when :delete
        begin
          @clauses = Clause.where(is_delete: false).find(params[:id])
          @clauses.update_column(:is_delete, true )
          render :json =>  {'message' => 'clauses deleted successfully'}
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
          render :json => {'error' => 'Clause not found'}
        end

    end

  end

  def clauses_locked
    case request.method_symbol
      when :post
        begin
          @clauses = Clause.where(is_delete: false).find(params[:id])
          data = JSON.parse(request.body.read)
          @clauses.update_column(:is_locked, data['is_locked'])
          @clauses.update_column(:locked_by, data['locked_by'])
          render :json => @clauses
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
          render :json => {'error' => 'Clause not found'}
        end
      when :get
        @clauses = Clause.where(is_delete: false, is_locked: true)
        render :json => @clauses
    end
  end

  def document
    case request.method_symbol
      when :get
        if params[:id]
          begin
            puts params[:id]
            @document = Document.find(params[:id])
            render :json => @document
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
            render :json => {'error' => 'Document not found'}
          end
        elsif
          @document = Document.where(is_delete: false)
          render :json => @document.order(id: :desc)
        end
      when :post
        data = JSON.parse(request.body.read)
        #
        if data['document'].to_s.empty?
          error = {}
          error['error'] = 'Document required.'
          render :json => error
        elsif
          @document = Document.new(:document => data['document'],
                                   :title => data['title'],
                                   :is_delete => false)

          @document.save
          if @document.save
            render :json => @document
          else
            @document = Document.all
            render :json => @document
          end
        end
      when :delete
        begin
          puts params[:id]
          @document = Document.where(is_delete: false).find(params[:id])
          @document.update_column(:is_delete, true )
          render :json => {'message' => 'Document deleted successfully'}
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
          render :json => {'error' => 'Document not found'}
        end
    end
  end


end

