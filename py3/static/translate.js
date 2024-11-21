document.addEventListener('DOMContentLoaded', function() { 
    const markdownInput = document.getElementById('markdown-input');
    const previewPane = document.getElementById('preview-pane');
    const hiddenBody = document.getElementById('hidden-body');
    // const blogForm = document.getElementById('blog-form');
    // let htmlContent = '';

    function updatePreview() {
        const markdownText = markdownInput.value;
        const htmlContent = marked.parse(markdownText, {
            breaks: true,
            gfm: true
        });
        previewPane.innerHTML = htmlContent;
        hiddenBody.value = htmlContent;
    }

    markdownInput.addEventListener('input', updatePreview);
    updatePreview();
});