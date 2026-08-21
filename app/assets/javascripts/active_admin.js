//= require active_admin/base
document.addEventListener("click", function (event) {
      var link = event.target.closest("a[data-method]");
      if (!link) return;
  
      event.preventDefault();
  
      if (link.dataset.confirm && !window.confirm(link.dataset.confirm)) {
          return;
      }
  
      var method = link.dataset.method;
      var csrfMeta = document.querySelector('meta[name="csrf-token"]');
      var csrfToken = csrfMeta ? csrfMeta.content : null;
  
      var form = document.createElement("form");
      form.method = "POST";
      form.action = link.href;
      form.style.display = "none";
  
      var methodInput = document.createElement("input");
      methodInput.type = "hidden";
      methodInput.name = "_method";
      methodInput.value = method;
      form.appendChild(methodInput);
  
      if (csrfToken) {
          var csrfInput = document.createElement("input");
          csrfInput.type = "hidden";
          csrfInput.name = "authenticity_token";
          csrfInput.value = csrfToken;
          form.appendChild(csrfInput);
      }
  
      document.body.appendChild(form);
      form.submit();
  });