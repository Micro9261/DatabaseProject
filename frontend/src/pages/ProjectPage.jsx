import { useOutletContext, useParams } from "react-router-dom";
import { ProjectCommentList } from "../components/ProjectCommentList";
import { ProjectInfo } from "../components/ProjectInfo";
import { useFetchWithAuth } from "../utils/fetchData";
import { useEffect, useState } from "react";

export function ProjectPage() {
  // console.log(params.ProjectId);
  const { ProjectId } = useParams();
  const fetchWithAuth = useFetchWithAuth();
  const { refreshSummary } = useOutletContext();

  const [project, setProject] = useState(null);
  const [comments, setComments] = useState([]);
  const [loading, setLoading] = useState(true);

  const refetchData = async () => {
    try {
      const [projectRes, commentsRes] = await Promise.all([
        fetchWithAuth(`/Projects/${ProjectId}`),
        fetchWithAuth(`/Projects/${ProjectId}/comments`),
      ]);

      if (projectRes.ok && commentsRes.ok) {
        const projectData = await projectRes.json();
        const commentsData = await commentsRes.json();
        setProject(projectData);
        setComments(commentsData);
      }
    } catch (err) {
      console.log("Error refetching project details", err);
    }
  };

  useEffect(() => {
    const fetchProjectDetails = async () => {
      setLoading(true);
      await refetchData();
      setLoading(false);
    };

    fetchProjectDetails();
  }, [ProjectId]);

  const handleEditProjectSubmit = async (newContent) => {
    try {
      const response = await fetchWithAuth(`/Projects/${ProjectId}`, {
        method: "PATCH",
        body: JSON.stringify({ content: newContent }),
      });

      if (response.ok) {
        setProject((prev) => ({ ...prev, content: newContent }));
        console.log("Project update successfully");
      } else {
        const errorData = await response.json();
        console.log("Failed updating project: ", errorData);
      }
    } catch (err) {
      console.log("Network error updating project", err);
    }
  };

  const handleEditProjectCommentSubmit = async (commentId, newContent) => {
    try {
      const response = await fetchWithAuth(
        `/Projects/${ProjectId}/comments/${commentId}`,
        {
          method: "PATCH",
          body: JSON.stringify({ content: newContent }),
        },
      );

      if (response.ok) {
        console.log("Project comment update successfully");
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

  const handleReplayProjectCommentSubmit = async (commentId, newContent) => {
    try {
      const response = await fetchWithAuth(`/Projects/${ProjectId}/comments`, {
        method: "POST",
        body: JSON.stringify({ content: newContent, parentId: commentId }),
      });

      if (response.ok) {
        console.log("Project comment add successfully");
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
  if (!project) return <div>Project not found.</div>;

  return (
    <div>
      <ProjectInfo
        author={project.author}
        title={project.title}
        date={project.create_date}
        content={project.content}
        views={project.views}
        likes={project.likes}
        setLike={false}
        saves={project.saves}
        setSave={true}
        comments={project.comments}
        onEditSubmit={(content) => {
          handleEditProjectSubmit(content);
        }}
        onReplaySubmit={(content) =>
          handleReplayProjectCommentSubmit(null, content)
        }
      />
      <ProjectCommentList
        commentsList={comments}
        onEdit={(id, content) => handleEditProjectCommentSubmit(id, content)}
        onReplay={(id, content) =>
          handleReplayProjectCommentSubmit(id, content)
        }
      />
    </div>
  );
}
