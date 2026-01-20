import { ThreadCommentList } from "../components/ThreadCommentList";
import { ProjectInfo } from "../components/ProjectInfo";
import { useOutletContext, useParams } from "react-router-dom";
import { useEffect, useState } from "react";
import { useFetchWithAuth } from "../utils/fetchData";

export function ThreadPage() {
  const { ThreadsId } = useParams();
  const fetchWithAuth = useFetchWithAuth();
  const { refreshSummary } = useOutletContext();

  const [thread, setThread] = useState(null);
  const [comments, setComments] = useState([]);
  const [loading, setLoading] = useState(true);

  const refetchData = async () => {
    try {
      const projectRes = await fetchWithAuth(`/Threads/${ThreadsId}`);
      const commentsRes = await fetchWithAuth(`/Threads/${ThreadsId}/comments`);

      if (projectRes.ok && commentsRes.ok) {
        const threadData = await projectRes.json();
        const commentsData = await commentsRes.json();

        setThread(threadData);
        setComments(commentsData);
      }
    } catch (err) {
      console.log("Error loading project details", err);
    }
  };

  useEffect(() => {
    const fetchProjectDetails = async () => {
      setLoading(true);
      await refetchData();
      setLoading(false);
    };

    fetchProjectDetails();
  }, [ThreadsId]);

  const handleEditThreadSubmit = async (newContent) => {
    try {
      const response = await fetchWithAuth(`/Threads/${ThreadsId}`, {
        method: "PATCH",
        body: JSON.stringify({ content: newContent }),
      });

      if (response.ok) {
        setThread((prev) => ({ ...prev, content: newContent }));
        console.log("Thread update successfully");
      } else {
        const errorData = await response.json();
        console.log("Failed updating project: ", errorData);
      }
    } catch (err) {
      console.log("Network error updating project", err);
    }
  };

  const handleEditThreadCommentSubmit = async (commentId, newContent) => {
    try {
      const response = await fetchWithAuth(
        `/Threads/${ThreadsId}/comments/${commentId}`,
        {
          method: "PATCH",
          body: JSON.stringify({ content: newContent }),
        },
      );

      if (response.ok) {
        await refetchData();
        refreshSummary();
        console.log("Thread comment update successfully");
      } else {
        const errorData = await response.json();
        console.log("Failed updating project: ", errorData);
      }
    } catch (err) {
      console.log("Network error updating project", err);
    }
  };

  const handleThreadProjectCommentSubmit = async (newContent) => {
    try {
      const response = await fetchWithAuth(`/Threads/${ThreadsId}/comments`, {
        method: "POST",
        body: JSON.stringify({ content: newContent, parentId: null }),
      });

      if (response.ok) {
        console.log("Thread comment add successfully");
        await refetchData();
        refreshSummary();
      } else {
        const errorData = await response.json();
        console.log("Failed updating project: ", errorData);
      }
    } catch (err) {
      console.log("Network error updating project", err);
    }
  };

  if (loading) return <div>Loading project details...</div>;
  if (!thread) return <div>Thread not found.</div>;
  return (
    <div>
      <ProjectInfo
        author={thread.author}
        title={thread.title}
        date={thread.create_date}
        content={thread.content}
        views={thread.views}
        likes={thread.likes}
        setLike={false}
        saves={thread.saves}
        setSave={true}
        comments={thread.comments}
        onEditSubmit={(content) => handleEditThreadSubmit(content)}
        onReplaySubmit={(content) => handleThreadProjectCommentSubmit(content)}
      />
      <ThreadCommentList
        onEdit={(id, content) => handleEditThreadCommentSubmit(id, content)}
        commentsList={comments}
      />
    </div>
  );
}
