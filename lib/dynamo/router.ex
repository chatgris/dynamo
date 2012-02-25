# Dynamo::Routes brings routing semantics to your module.
#
# ## Examples
#
#     defmodule MyApp do
#       use Dynamo::Router
#
#       get "users/:id" do
#         response.write_head 200, [{ "Content-Type", "application/json" }]
#         response.end JSON.encode(User.find(id))
#       end
#     end
#
defmodule Dynamo::Router do
  defmacro __using__(module, _) do
    Module.add_compile_callback module, __MODULE__

    quote do
      @dynamo_router true
      import Dynamo::Router::DSL

      @overridable true
      def service(request, response) do
        { :abs_path, path } = request.get(:uri)
        verb = request.get(:method)
        path = Dynamo::Router::Utils.split(path)
        dispatch(verb, path, request, response)
      end

      @overridable true
      def not_found(request, _response) do
        request.respond(404, [], "Status: 404")
      end
    end
  end

  defmacro __compiling__(_) do
    quote do
      def dispatch(_, _, request, response) do
        not_found(request, response)
      end
    end
  end
end