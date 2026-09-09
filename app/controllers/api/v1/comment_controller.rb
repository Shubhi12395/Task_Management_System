class Api::V1::CommentController < ApiController
  def create
    if params[:task_id]
      commentable=current_user.tasks.find_by(id: params[:task_id])
    else
      commentable=current_user
    end
    if commentable
      comment = commentable.comments.new(comment_params)
      if comment.save
        render json: { message: "Comment created successfully", comment: CommentSerializer.new(comment) }, status: :created
      else
        render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Commentable not found" }, status: :not_found
    end
  end
  def index
    if params[:task_id]
      commentables=current_user.tasks.includes(:project).find_by(id: params[:task_id])
      @pagy, @comments = pagy(commentables.comments)

    else
      commentables=current_user.comments
      @pagy, @comments = pagy(commentables)
    end
    serialized_comments = ActiveModelSerializers::SerializableResource.new(@comments, each_serializer: CommentSerializer)
    render json: { comments: serialized_comments, meta: pagy_metadata(@pagy) }, status: :ok
  end

  def delete
    commentable =current_user.tasks.find_by!(id: params[:task_id])
    if commentable.present?
      comment = commentable.comments.find_by!(id: params[:id])
      comment.destroy
      render json: { message: "comment deleted successfully" }, status: :ok
    else
      render json: { error: "Commentable not found" }, status: :not_found
    end
  rescue
    ActiveRecord::RecordNotFound
    render json: { error: "Comment not found" }, status: :not_found
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
